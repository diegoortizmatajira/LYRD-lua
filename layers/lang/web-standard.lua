local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

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
		{ "b0o/schemastore.nvim" },
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
		"css-lsp",
		"emmet-language-server",
		"emmet-ls",
		"eslint-lsp",
		"json-lsp",
		"json-to-struct",
		"lemminx",
		"prettier",
		"taplo",
		"xmlformatter",
		"yaml-language-server",
		"yamlfmt",
		"yamllint",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.prettier.with({ -- For most standard file types
			extra_filetypes = { "htmldjango" },
		}),
	})
	lsp.format_with_conform("xml", {
		"xmlformatter",
		lsp_format = "prefer",
	})
end

function L.complete()
	vim.lsp.enable({
		"jsonls",
		"yamlls",
		"taplo",
		"emmet_language_server",
		"lemminx",
	})
end

return L
