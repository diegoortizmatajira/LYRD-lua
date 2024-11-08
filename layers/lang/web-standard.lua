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

function L.preparation(_)
	lsp.mason_ensure({
		"json-lsp",
		"json-to-struct",
		"prettier",
		"typescript-language-server",
		"vue-language-server",
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
	local vue_typescript_plugin = require("mason-registry").get_package("vue-language-server"):get_install_path()
		.. "/node_modules/@vue/language-server"
		.. "/node_modules/@vue/typescript-plugin"
	lsp.enable("ts_ls", {
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = vue_typescript_plugin,
					languages = { "javascript", "typescript", "vue" },
				},
			},
		},
		filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
			"vue",
		},
	})
	lsp.enable("volar", {})
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
end

return L
