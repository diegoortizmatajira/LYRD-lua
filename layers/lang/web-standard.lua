local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Web Standard Languages" }

function L.plugins(s)
	setup.plugin(s, {
		"pangloss/vim-javascript",
		"b0o/schemastore.nvim",
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
			"heilgar/nvim-http-client",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			opts = {},
			config = function(opts)
				require("http_client").setup(opts)
				require("telescope").load_extension("http_client")
			end,
		},
	})
end

function L.preparation(_)
	lsp.mason_ensure({
		"json-lsp",
		"json-to-struct",
		"yaml-language-server",
		"prettier",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.prettier.with({ -- For most standard file types
			extra_filetypes = { "htmldjango" },
		}),
	})
end

function L.settings(_)
	vim.g.javascript_plugin_jsdoc = 1
	vim.g.javascript_plugin_ngdoc = 1
	vim.g.javascript_plugin_flow = 1
end

function L.complete(_)
	lsp.enable("jsonls", {
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = {
					enabled = true,
				},
			},
		},
	})
	lsp.enable("yamlls", {
		settings = {
			yaml = {
				hover = true,
				completion = true,
				validate = true,
				schemaStore = {
					enable = true,
					url = "https://www.schemastore.org/api/json/catalog.json",
				},
				schemas = require("schemastore").yaml.schemas(),
			},
		},
	})
end

return L
