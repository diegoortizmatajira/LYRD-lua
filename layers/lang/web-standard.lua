local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Web Standard Languages",
	required_plugins = {
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"windwp/nvim-autopairs",
			},
			opts = {},
		},
	},
	required_mason_packages = {
		"html-lsp",
		"css-lsp",
		"emmet-language-server",
		"emmet-ls",
		"prettier",
	},
	required_treesitter_parsers = {
		"html",
		"css",
		"scss",
	},
	required_enabled_lsp_servers = {
		"emmet_language_server",
		"cssls",
		"html",
	},
}

function L.preparation()
	local null_ls = require("null-ls")
	local lsp = require("LYRD.layers.lsp")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.prettier.with({ -- For most standard filetypes
			extra_filetypes = { "htmldjango" },
		}),
	})
end

return declarative_layer.apply(L)
