local join = require("LYRD.utils").join_paths
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
						location = join(
							vim.fn.expand("$MASON"),
							"packages",
							"vue-language-server",
							"node_modules",
							"@vue",
							"language-server"
						),

						languages = { "vue" },
						configNamespace = "typescript",
					},
					{
						name = "@angular/language-server",
						location = join(
							vim.fn.expand("$MASON"),
							"packages",
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
