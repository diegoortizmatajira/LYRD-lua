local setup = require("LYRD.setup")

_G.LYRD_setup = {
	layers = {
		"LYRD.layers.general",
		"LYRD.layers.neovide", -- Neovide settings
		"LYRD.layers.mappings",
		"LYRD.layers.commands",
		"LYRD.layers.lyrd-commands",
		"LYRD.layers.lyrd-ui",
		"LYRD.layers.lyrd-keyboard",
		"LYRD.layers.motions",
		"LYRD.layers.dev",
		"LYRD.layers.test",
		"LYRD.layers.format",
		"LYRD.layers.git",
		"LYRD.layers.lsp",
		"LYRD.layers.treesitter",
		"LYRD.layers.filetree",
		"LYRD.layers.telescope",
		"LYRD.layers.snippets",
		"LYRD.layers.completion",
		"LYRD.layers.debug",
		"LYRD.layers.lang.go",
		"LYRD.layers.lang.csharp",
		"LYRD.layers.lang.lua",
		"LYRD.layers.lang.python",
		"LYRD.layers.lang.typescript",
		"LYRD.layers.lang.json",
		"LYRD.layers.lang.cmake",
	},
}

setup.load(_G.LYRD_setup)
