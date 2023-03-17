local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "LSP" }

local capabilities = nil

local plugged_capabilities = function()
	return vim.lsp.protocol.make_client_capabilities()
end

function L.plug_capabilities(plug_handler)
	plugged_capabilities = plug_handler(plugged_capabilities)
end

function L.plugins(s)
	setup.plugin(s, {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-lint",
		"folke/trouble.nvim",
		"j-hui/fidget.nvim",
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	})
end

function L.settings(s)
	require("mason").setup()
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

	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
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

	require("trouble").setup()
	require("fidget").setup()
	require("lsp_lines").setup()

	commands.implement(s, "*", {
		LYRDLSPFindReferences = vim.lsp.buf.references,
		LYRDLSPFindCodeActions = vim.lsp.buf.code_action,
		LYRDLSPFindRangeCodeActions = vim.lsp.buf.range_code_action,
		LYRDLSPFindLineDiagnostics = vim.diagnostic.show_line_diagnostics,
		LYRDLSPFindDocumentDiagnostics = ":TroubleToggle document_diagnostics",
		LYRDLSPFindWorkspaceDiagnostics = ":TroubleToggle workspace_diagnostics",
		LYRDLSPFindImplementations = vim.lsp.buf.implementation,
		LYRDLSPFindDefinitions = vim.lsp.buf.definition,
		LYRDLSPFindDeclaration = vim.lsp.buf.declaration,
		LYRDLSPHoverInfo = vim.lsp.buf.hover,
		LYRDLSPSignatureHelp = vim.lsp.buf.signature_help,
		LYRDLSPFindTypeDefinition = vim.lsp.buf.type_definition,
		LYRDLSPRename = vim.lsp.buf.rename,
		LYRDLSPGotoNextDiagnostic = vim.diagnostic.goto_next,
		LYRDLSPGotoPrevDiagnostic = vim.diagnostic.goto_prev,
		LYRDLSPShowDocumentDiagnosticLocList = ":TroubleToggle document_diagnostics",
		LYRDLSPShowWorkspaceDiagnosticLocList = ":TroubleToggle workspace_diagnostics",
		LYRDViewLocationList = ":TroubleToggle loclist",
		LYRDViewQuickFixList = ":TroubleToggle quickfix",
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

function L.complete(_)
	require("mason-tool-installer").setup({

		-- a list of all tools you want to ensure are installed upon
		-- start; they should be the names Mason uses for each tool
		ensure_installed = {
			"angular-language-server",
			"bash-language-server",
			"clang-format",
			"cmake-language-server",
			"css-lsp",
			"debugpy",
			"delve",
			"dockerfile-language-server",
			"editorconfig-checker",
			"firefox-debug-adapter",
			"go-debug-adapter",
			"gofumpt",
			"goimports",
			"golangci-lint",
			"golangci-lint-langserver",
			"golines",
			"gomodifytags",
			"gopls",
			"gotests",
			"impl",
			"json-lsp",
			"json-to-struct",
			"lua-language-server",
			"luacheck",
			"luaformatter",
			"luau-lsp",
			"markdownlint",
			"netcoredbg",
			"omnisharp",
			"prettier",
			"pylint",
			"pyright",
			"python-lsp-server",
			"stylua",
			"vim-language-server",
			"yamlfmt",
			"yamllint",
			"yapf",
		},

		-- if set to true this will check each tool for updates. If updates
		-- are available the tool will be updated. This setting does not
		-- affect :MasonToolsUpdate or :MasonToolsInstall.
		-- Default: false
		auto_update = false,

		-- automatically install / update on startup. If set to false nothing
		-- will happen on startup. You can use :MasonToolsInstall or
		-- :MasonToolsUpdate to install tools and check for updates.
		-- Default: true
		run_on_start = true,

		-- set a delay (in ms) before the installation starts. This is only
		-- effective if run_on_start is set to true.
		-- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
		-- Default: 0
		start_delay = 3000, -- 3 second delay

		-- Only attempt to install if 'debounce_hours' number of hours has
		-- elapsed since the last time Neovim was started. This stores a
		-- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
		-- This is only relevant when you are using 'run_on_start'. It has no
		-- effect when running manually via ':MasonToolsInstall' etc....
		-- Default: nil
		debounce_hours = 5, -- at least 5 hours between attempts to install/update
	})
end

return L
