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
		deno = {
			enable = true,
			suggest = {
				imports = {
					hosts = {
						["https://crux.land"] = true,
						["https://deno.land"] = true,
						["https://x.nest.land"] = true,
					},
				},
			},
		},
	},
}
