return {
	filetypes = {
		"vue",
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.expand("$MASON/packages/vue-language-server")
							.. "/node_modules/@vue/language-server",

						languages = { "vue" },
						configNamespace = "typescript",
					},
				},
			},
		},
	},
}
