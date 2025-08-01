local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Web Standard Languages" }

function L.plugins()
	setup.plugin({
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"windwp/nvim-autopairs",
			},
			opts = {},
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"html-lsp",
		"css-lsp",
		"emmet-language-server",
		"emmet-ls",
		"prettier",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.prettier.with({ -- For most standard file types
			extra_filetypes = { "htmldjango" },
		}),
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"html",
		"css",
		"scss",
	})
end

function L.complete()
	vim.lsp.enable({
		"emmet_language_server",
		"cssls",
		"html",
	})
end

return L
