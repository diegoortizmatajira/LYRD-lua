local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Web Standard Languages" }

function L.plugins()
	setup.plugin({
		{
			"pangloss/vim-javascript",
			init = function()
				vim.g.javascript_plugin_jsdoc = 1
				vim.g.javascript_plugin_ngdoc = 1
				vim.g.javascript_plugin_flow = 1
			end,
			ft = { "js" },
		},
		"b0o/schemastore.nvim",
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"windwp/nvim-autopairs",
			},
			opts = {},
			ft = { "json", "yaml" },
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"json-lsp",
		"json-to-struct",
		"yaml-language-server",
		"prettier",
		"emmet-language-server",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.prettier.with({ -- For most standard file types
			extra_filetypes = { "htmldjango" },
		}),
	})
end

function L.complete()
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
	lsp.enable("taplo", {
		settings = {
			evenBetterToml = {
				schema = {
					-- add additional schemas
					associations = {
						["example\\.toml$"] = "https://json.schemastore.org/example.json",
					},
				},
			},
		},
	})
	lsp.enable("emmet_language_server", {
		settings = {
			filetypes = {
				"css",
				"eruby",
				"html",
				"javascript",
				"javascriptreact",
				"less",
				"sass",
				"scss",
				"pug",
				"typescriptreact",
				"vue",
			},
		},
	})
end

return L
