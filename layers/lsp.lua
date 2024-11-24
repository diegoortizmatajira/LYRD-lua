local setup = require("LYRD.setup")
local utils = require("LYRD.utils")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "LSP" }

local capabilities = nil
local mason_required = {}
local null_ls_sources = {}
local null_ls_registered = {}
local mason_opts = {
	ui = {
		check_outdated_packages_on_open = true,
		width = 0.8,
		height = 0.9,
		border = "rounded",
		keymaps = {
			toggle_package_expand = "<CR>",
			install_package = "i",
			update_package = "u",
			check_package_version = "c",
			update_all_packages = "U",
			check_outdated_packages = "C",
			uninstall_package = "X",
			cancel_installation = "<C-c>",
			apply_language_filter = "<C-f>",
		},
		icons = {
			package_installed = icons.status.checked,
			package_pending = icons.status.unknown,
			package_uninstalled = icons.status.unchecked,
		},
	},

	-- NOTE: should be available in $PATH
	install_root_dir = utils.join_paths(vim.fn.stdpath("data"), "mason"),

	pip = {
		upgrade_pip = false,
		-- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
		-- and is not recommended.
		--
		-- Example: { "--proxy", "https://proxyserver" }
		install_args = {},
	},

	-- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
	-- debugging issues with package installations.
	log_level = vim.log.levels.INFO,

	-- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
	-- packages that are requested to be installed will be put in a queue.
	max_concurrent_installers = 4,

	-- [Advanced setting]
	-- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
	-- multiple registries, the registry listed first will be used.
	registries = {
		"lua:mason-registry.index",
		"github:mason-org/mason-registry",
		"github:nvim-java/mason-registry",
		"github:crashdummyy/mason-registry",
	},

	-- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
	-- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
	providers = {
		"mason.providers.registry-api",
		"mason.providers.client",
	},

	github = {
		-- The template URL to use when downloading assets from GitHub.
		-- The placeholders are the following (in order):
		-- 1. The repository (e.g. "rust-lang/rust-analyzer")
		-- 2. The release version (e.g. "v0.3.0")
		-- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
		download_url_template = "https://github.com/%s/releases/download/%s/%s",
	},
}

local function add_mason_bin_to_path(append)
	local p = utils.join_paths(mason_opts.install_root_dir, "bin")
	utils.include_in_system_path(p, append)
end

local plugged_capabilities = function()
	local result = vim.lsp.protocol.make_client_capabilities()
	result.textDocument.completion.completionItem.snippetSupport = true
	result.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	}
	result.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	return result
end

local function setup_default_providers()
	local null_ls = require("null-ls")
	L.null_ls_register_sources({
		null_ls.builtins.code_actions.gitsigns,
		null_ls.builtins.formatting.yamlfmt,
		null_ls.builtins.formatting.clang_format,
	})
end

function L.plug_capabilities(plug_handler)
	plugged_capabilities = plug_handler(plugged_capabilities)
end

function exclude_lsp_lines_from_filetypes(filetypes)
	for _, filetype in ipairs(filetypes) do
		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetype,
			callback = function()
				local previous = not require("lsp_lines").toggle()
				if not previous then
					require("lsp_lines").toggle()
				end
			end,
		})
	end
end

function L.plugins(s)
	setup.plugin(s, {
		{ "neovim/nvim-lspconfig" },
		{
			"williamboman/mason.nvim",
			config = false,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			config = false,
			dependencies = {
				"williamboman/mason.nvim",
				"neovim/nvim-lspconfig",
			},
		},
		{
			"nvimtools/none-ls.nvim",
			config = false,
		},
		{
			"jay-babu/mason-null-ls.nvim",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = {
				"williamboman/mason.nvim",
				"nvimtools/none-ls.nvim",
			},
			config = false,
		},
		{
			"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
			config = function(opts)
				require("lsp_lines").setup(opts)
				exclude_lsp_lines_from_filetypes({ "lazy" })
			end,
			opts = {},
		},
		{
			"whoissethdaniel/mason-tool-installer.nvim",
			config = false,
			dependencies = { "williamboman/mason.nvim" },
		},
		{
			"folke/trouble.nvim",
			opts = {},
		},
	})
end

function L.preparation(_)
	add_mason_bin_to_path()
	L.mason_ensure({
		"angular-language-server",
		"bash-language-server",
		"clang-format",
		"css-lsp",
		"dockerfile-language-server",
		"editorconfig-checker",
		"emmet-ls",
		"eslint-lsp",
		"firefox-debug-adapter",
		"marksman",
		"taplo",
		"lemminx",
		"node-debug2-adapter",
		"sql-formatter",
		"sqlls",
		"vim-language-server",
		"yamlfmt",
		"yamllint",
		"yapf",
	})
	setup_default_providers()
end

function L.settings(s)
	require("mason").setup(mason_opts) -- Recommended not to lazy load
	require("mason-tool-installer").setup({
		ensure_installed = mason_required,
	})
	require("mason-lspconfig").setup()
	require("mason-lspconfig").setup_handlers({
		-- The first entry (without a key) will be the default handler
		-- and will be called for each installed server that doesn't have
		-- a dedicated handler.
		function(server_name) -- default handler (optional)
			L.enable(server_name, {})
		end,
		-- Next, you can provide targeted overrides for specific servers.
		-- For example, a handler override for the `rust_analyzer`:
		-- ["rust_analyzer"] = function()
		--   require("rust-tools").setup{}
		-- end
	})

	-- Configures the null language server
	local null_ls = require("null-ls")
	null_ls.setup({
		sources = null_ls_sources,
	})
	for _, custom_register in ipairs(null_ls_registered) do
		null_ls.register(custom_register)
	end

	require("mason-null-ls").setup({
		ensure_installed = nil,
		automatic_installation = true,
	})
	local signs = {
		{ name = "DiagnosticSignError", text = icons.diagnostic.error },
		{ name = "DiagnosticSignWarn", text = icons.diagnostic.warning },
		{ name = "DiagnosticSignHint", text = icons.diagnostic.hint },
		{ name = "DiagnosticSignInfo", text = icons.diagnostic.info },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		virtual_text = false,
		-- show signs
		signs = { active = signs },
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

	vim.lsp.handlers["textDocument/signatureHelp"] =
		vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

	-- Enable rounded borders in :LspInfo window.
	require("lspconfig.ui.windows").default_options.border = "rounded"

	commands.implement(s, "*", {
		{ cmd.LYRDToolManager, ":Mason" },
		{
			cmd.LYRDBufferFormat,
			function()
				vim.lsp.buf.format({ async = true, timeout_ms = 3000 })
			end,
		},
		{ cmd.LYRDLSPFindReferences, vim.lsp.buf.references },
		{ cmd.LYRDLSPFindCodeActions, vim.lsp.buf.code_action },
		{ cmd.LYRDLSPFindRangeCodeActions, vim.lsp.buf.range_code_action },
		{ cmd.LYRDLSPFindLineDiagnostics, vim.diagnostic.show_line_diagnostics },
		{ cmd.LYRDLSPFindDocumentDiagnostics, ":Trouble diagnostics toggle filter.buf=0" },
		{ cmd.LYRDLSPFindWorkspaceDiagnostics, ":Trouble diagnostics toggle" },
		{ cmd.LYRDLSPFindImplementations, vim.lsp.buf.implementation },
		{ cmd.LYRDLSPFindDefinitions, vim.lsp.buf.definition },
		{ cmd.LYRDLSPFindDeclaration, vim.lsp.buf.declaration },
		{ cmd.LYRDLSPHoverInfo, vim.lsp.buf.hover },
		{ cmd.LYRDLSPSignatureHelp, vim.lsp.buf.signature_help },
		{ cmd.LYRDLSPFindTypeDefinition, vim.lsp.buf.type_definition },
		{ cmd.LYRDLSPRename, vim.lsp.buf.rename },
		{ cmd.LYRDLSPGotoNextDiagnostic, vim.diagnostic.goto_next },
		{ cmd.LYRDLSPGotoPrevDiagnostic, vim.diagnostic.goto_prev },
		{ cmd.LYRDLSPShowDocumentDiagnosticLocList, ":Trouble diagnostics toggle filter.buf=0" },
		{ cmd.LYRDLSPShowWorkspaceDiagnosticLocList, ":Trouble diagnostics toggle" },
		{ cmd.LYRDViewLocationList, ":Trouble loclist toggle" },
		{ cmd.LYRDViewQuickFixList, ":Trouble qflist toggle" },
		{
			cmd.LYRDDiagnosticLinesToggle,
			function()
				require("lsp_lines").toggle()
			end,
		},
	})
end

function L.enable(server, options)
	if capabilities == nil then
		capabilities = plugged_capabilities()
	end
	options = options or {}
	options.capabilities = options.capabilities or capabilities
	require("lspconfig")[server].setup(options)
end

function L.mason_ensure(tools)
	for _, tool in ipairs(tools) do
		table.insert(mason_required, tool)
	end
end

function L.null_ls_register_sources(sources)
	for _, source in ipairs(sources) do
		table.insert(null_ls_sources, source)
	end
end

function L.null_ls_register(custom_register)
	table.insert(null_ls_registered, custom_register)
end

function L.complete(_) end

function L.format_handler(server_name)
	-- Returns a handler that format using the given lsp
	return function()
		vim.lsp.buf.format({
			filter = function(client)
				return client.name == server_name
			end,
			async = false,
		})
	end
end

return L
