local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.Development: LYRD.setup.Module
local L = { name = "Development Tools" }

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
			-- Adds support for viewing colors in color values in the editor
			"norcalli/nvim-colorizer.lua",
		},
		{
			"ellisonleao/dotenv.nvim",
			opts = {},
			cmd = { "Dotenv", "DotenvGet" },
		},
		{
			"jesseleite/nvim-macroni",
			lazy = false,
			opts = {
				-- All of your `setup(opts)` and saved macros will go here
			},
		},
	})
end

function L.settings()
	commands.implement("*", {
		{
			cmd.LYRDSearchMacros,
			function()
				require("telescope").extensions.macroni.saved_macros()
			end,
		},
	})
end

return L
