local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Tasks" }

function L.plugins(s)
	setup.plugin(s, {
		{
			--TODO: Make the most out of this one
			"stevearc/overseer.nvim",
			opts = {
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
				},
			},
			lazy = true,
		},
		{
			"kndndrj/nvim-projector",
			dependencies = {
				-- required:
				"muniftanjim/nui.nvim",
				"kndndrj/projector-neotest",
				"kndndrj/projector-vscode",
			},
			config = function()
				require("projector").setup({
					loaders = {
						require("projector_vscode").LaunchJsonLoader:new(),
						require("projector_vscode").TasksJsonLoader:new(),
						require("projector.loaders").BuiltinLoader:new(),
						require("projector.loaders").DapLoader:new(),
					},
					outputs = {
						require("projector.outputs").TaskOutputBuilder:new(),
						require("projector.outputs").DadbodOutputBuilder:new(),
						require("projector.outputs").DapOutputBuilder:new(),
						require("projector_neotest").OutputBuilder:new(),
					},
				})
			end,
			lazy = true,
		},
		{
			"kndndrj/projector-neotest",
			dependencies = {
				"nvim-neotest/neotest",
			},
			lazy = true,
		},
		{
			"kndndrj/projector-vscode",
			lazy = true,
		},
	})
end

function L.settings(s)
	local debug = require("LYRD.layers.debug")
	commands.implement(s, "*", {
		{
			cmd.LYRDDebugStart,
			debug.start_handler(function()
				require("projector").continue()
			end),
		},
	})
end

return L
