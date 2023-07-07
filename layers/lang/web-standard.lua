local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Web Standard Languages" }

function L.plugins(s)
	setup.plugin(s, {
		"pangloss/vim-javascript",
		"leafgarland/typescript-vim",
		"b0o/schemastore.nvim",
	})
end

function L.settings(_)
	vim.g.javascript_plugin_jsdoc = 1
	vim.g.javascript_plugin_ngdoc = 1
	vim.g.javascript_plugin_flow = 1
	lsp.mason_ensure({
		"json-lsp",
		"json-to-struct",
		"prettier",
		"typescript-language-server",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.prettier.with({ -- For most standard file types
			extra_filetypes = { "htmldjango" },
		}),
		null_ls.builtins.formatting.taplo, -- For TOML files
	})
end

function L.complete(_)
	lsp.enable("tsserver", {})
	lsp.enable(
		"jsonls",
		{ settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enabled = true } } } }
	)
end

return L
