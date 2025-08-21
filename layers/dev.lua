local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Development" }

function L.plugins()
	setup.plugin({
		{
			-- Adds support for commenting code with TODOs, FIXMEs, etc.
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
		},
		{
			-- Adds support for viewing code outlines in a floating window
			"stevearc/aerial.nvim",
			opts = {
				close_on_select = true,
			},
			-- Optional dependencies
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
			cmd = { "AerialToggle" },
		},
		{
			-- Adds support for viewing colors in color values in the editor
			"norcalli/nvim-colorizer.lua",
		},
		{
			"ellisonleao/dotenv.nvim",
			opts = {},
			cmd = { "Dotenv", "DotenvGet" },
		},
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDViewCodeOutline, ":AerialToggle" },
		{ cmd.LYRDCodeMakeTasks, ":MakeitOpen" },
		{ cmd.LYRDCodeAddDocumentation, ":Neogen" },
	})
end

return L
