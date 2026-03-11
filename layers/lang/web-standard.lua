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
	required_null_ls_sources = {
		declarative_layer.source_with_opts("null-ls.builtins.formatting.prettier", {
			extra_filetypes = { "htmldjango" },
		}),
	},
}

return declarative_layer.apply(L)
