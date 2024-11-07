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
		"LYRD.layers.clipboard",
		"LYRD.layers.tmux",
		"LYRD.layers.motions",
		"LYRD.layers.dev",
		"LYRD.layers.test",
		"LYRD.layers.git",
		"LYRD.layers.lsp",
		"LYRD.layers.treesitter",
		"LYRD.layers.filetree",
		"LYRD.layers.telescope",
		"LYRD.layers.snippets",
		"LYRD.layers.completion",
		"LYRD.layers.debug",
		"LYRD.layers.database",
		"LYRD.layers.docker",
		"LYRD.layers.kubernetes",
		"LYRD.layers.projector", -- Must be after debug and database
		"LYRD.layers.ai-tabnine",
		-- "LYRD.layers.ai-copilot",
		-- "LYRD.layers.ai-chat-gpt",
		"LYRD.layers.lang.go",
		"LYRD.layers.lang.kotlin",
		"LYRD.layers.lang.csharp",
		"LYRD.layers.lang.lua",
		"LYRD.layers.lang.python",
		"LYRD.layers.lang.rust",
		"LYRD.layers.lang.web-standard",
		"LYRD.layers.lang.cmake",
		"LYRD.layers.lang.sql",
		-- "LYRD.layers.tab-behavior",
	},
}

setup.load(_G.LYRD_setup)
