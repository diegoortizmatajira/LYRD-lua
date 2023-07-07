local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local format = require("LYRD.layers.format")

local L = { name = "TypeScript Language" }

function L.plugins(s)
	setup.plugin(s, { "pangloss/vim-javascript", "leafgarland/typescript-vim" })
end

function L.settings(_)
	vim.g.javascript_plugin_jsdoc = 1
	vim.g.javascript_plugin_ngdoc = 1
	vim.g.javascript_plugin_flow = 1
	lsp.mason_ensure({
        "prettier",
        "typescript-language-server",
    })
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.gofumpt,
	})
	format.add_formatters("typescript", { require("formatter.filetypes.typescript").prettier })
end

function L.complete(_)
	lsp.enable("tsserver", {})
end

return L
