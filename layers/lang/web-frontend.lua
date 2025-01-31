local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Web frontend" }

function L.plugins(s)
	setup.plugin({
		{
			"leafgarland/typescript-vim",
			ft = { "ts", "tsx", "vue" },
		},
	})
end

function L.preparation(_)
	lsp.mason_ensure({
		"typescript-language-server",
		"vue-language-server",
	})
end

function L.settings(_) end

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
end

return L
