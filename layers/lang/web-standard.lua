local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Web Standard Languages: HTML, CSS, SCSS",
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
		{
			"jezda1337/nvim-html-css",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {
				enable_on = {
					"html",
					"htmldjango",
					"tsx",
					"jsx",
					"erb",
					"svelte",
					"vue",
					"blade",
					"php",
					"templ",
					"astro",
				},
				handlers = {
					definition = {
						bind = "gd",
					},
					hover = {
						bind = "K",
						wrap = true,
						border = "none",
						position = "cursor",
					},
				},
				documentation = {
					auto_show = true,
				},
				peek = {
					enabled = true,
					border = "rounded",
					position = "center",
					width = 0.5,
					height = 0.5,
					focus = true,
					style = "minimal",
				},
				style_sheets = {
					"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
					"https://cdnjs.cloudflare.com/ajax/libs/bulma/1.0.3/css/bulma.min.css",
					"./index.css", -- `./` refers to the current working directory.
				},
			},
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
	required_formatter_per_filetype = {
		{
			target_filetype = {
				"html",
				"htmldjango",
				"less",
				"css",
				"scss",
			},
			format_settings = { "prettier" },
		},
	},
}

return declarative_layer.apply(L)
