local setup = require("LYRD.setup")

_G.LYRD_setup = {
	layers = {
		"LYRD.layers.general",
		"LYRD.layers.neovide", -- Neovide settings
		"LYRD.layers.icons",
		"LYRD.layers.mappings",
		"LYRD.layers.commands",
		"LYRD.layers.lyrd-commands",
		"LYRD.layers.lyrd-ui",
		"LYRD.layers.lyrd-keyboard",
		"LYRD.layers.clipboard",
		"LYRD.layers.tmux",
		"LYRD.layers.motions",
		"LYRD.layers.file_templates",
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
		"LYRD.layers.tasks", -- Must be after debug and database
		"LYRD.layers.ai-codeium",
		-- "LYRD.layers.ai-tabnine",
		-- "LYRD.layers.ai-copilot",
		-- "LYRD.layers.ai-chat-gpt",
		"LYRD.layers.lang.cmake",
		"LYRD.layers.lang.dotnet",
		"LYRD.layers.lang.go",
		"LYRD.layers.lang.kotlin",
		"LYRD.layers.lang.lua",
		"LYRD.layers.lang.markdown",
		"LYRD.layers.lang.python",
		"LYRD.layers.lang.rust",
		"LYRD.layers.lang.sql",
		"LYRD.layers.lang.web-frontend",
		"LYRD.layers.lang.web-standard",
	},
}

setup.load(_G.LYRD_setup)
