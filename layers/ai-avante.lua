local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Avante-AI" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			lazy = false,
			version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
			opts = {
				provider = "copilot",
				auto_suggestions_provider = "copilot",
			},
			-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
			build = "make",
			-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
			dependencies = {
				"stevearc/dressing.nvim",
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				--- The below dependencies are optional,
				"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
				"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
				"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
				"zbirenbaum/copilot.lua", -- for providers='copilot'
				"HakonHarnes/img-clip.nvim",
				"MeanderingProgrammer/render-markdown.nvim",
			},
		},
	})
end

function L.settings(s)
	commands.implement("*", {
		{ cmd.LYRDAIAssistant, ":AvanteToggle" },
	})
end

return L
