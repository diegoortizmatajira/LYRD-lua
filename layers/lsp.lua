local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "LSP" }

local capabilities = nil
local mason_required = {}
local null_ls_sources = {}
local null_ls_registered = {}

local plugged_capabilities = function()
	return vim.lsp.protocol.make_client_capabilities()
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

function L.plugins(s)
	setup.plugin(s, {
		{ "nvimtools/none-ls.nvim" },
		{
			"williamboman/mason-lspconfig.nvim",
			opts = {},
			config = function()
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
			end,
			dependencies = {
				"williamboman/mason.nvim",
				"neovim/nvim-lspconfig",
			},
		},
		{ "williamboman/mason.nvim", opts = {}, lazy = false },
		{ "neovim/nvim-lspconfig" },
		{ "folke/trouble.nvim", opts = {} },
		{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim", opts = {} },
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = { "williamboman/mason.nvim" },
		},
	})
end

function L.preparation(_)
	-- L.mason_ensure({
	-- 	"angular-language-server",
	-- 	"bash-language-server",
	-- 	"clang-format",
	-- 	"css-lsp",
	-- 	"dockerfile-language-server",
	-- 	"editorconfig-checker",
	-- 	"emmet-ls",
	-- 	"eslint-lsp",
	-- 	"firefox-debug-adapter",
	-- 	"marksman",
	-- 	"taplo",
	-- 	"lemminx",
	-- 	"node-debug2-adapter",
	-- 	"sql-formatter",
	-- 	"sqlls",
	-- 	"vim-language-server",
	-- 	"yamlfmt",
	-- 	"yamllint",
	-- 	"yapf",
	-- })
end

function L.settings(s)
	require("mason-tool-installer").setup({
		ensure_installed = mason_required,
	})

	-- Configures the null language server
	local null_ls = require("null-ls")
	null_ls.setup({
		sources = null_ls_sources,
	})
	for _, custom_register in ipairs(null_ls_registered) do
		null_ls.register(custom_register)
	end

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

	commands.implement(s, "*", {
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
	setup_default_providers()
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

return L
