local lsp = require("LYRD.layers.lsp")
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
						location = lsp.get_pkg_path("vue-language-server", "node_modules", "@vue", "language-server"),
						languages = { "vue" },
						configNamespace = "typescript",
					},
					{
						name = "@angular/language-server",
						location = lsp.get_pkg_path(
							"angular-language-server",
							"node_modules",
							"@angular",
							"language-server"
						),
						enableForWorkspaceTypeScriptVersions = false,
					},
				},
			},
		},
	},
}
