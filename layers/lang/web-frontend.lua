local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Web frontend" }

function L.plugins()
	setup.plugin({
		{
			"leafgarland/typescript-vim",
			ft = { "ts", "tsx", "vue" },
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"typescript-language-server",
		"vue-language-server",
	})
end

function L.settings() end

function L.complete()
	lsp.enable("ts_ls", {
		filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
			"vue",
		},
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = vim.fn.stdpath("data")
						.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",

					languages = { "vue" },
				},
			},
		},
		settings = {},
	})
	lsp.enable("volar", {
		init_options = {
			vue = {
				hybridMode = true,
			},
		},
		settings = {},
	})
end

return L
