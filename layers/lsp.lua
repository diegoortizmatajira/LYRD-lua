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

return L
