return {
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
				onSave = true,
				forwardSearchAfter = false,
			},
			forwardSearch = {
				executable = "zathura",
				args = { "--synctex-forward", "%l:1:%f", "%p" },
			},
			chktex = {
				onOpenAndSave = true,
				onEdit = false,
			},
			diagnostics = {
				ignoredPatterns = {},
			},
			latexindent = {
				modifyLineBreaks = false,
			},
		},
	},
}
