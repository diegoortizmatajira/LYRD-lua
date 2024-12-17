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
		},
		{
			"kndndrj/nvim-projector",
			dependencies = {
				-- required:
				"muniftanjim/nui.nvim",
				"kndndrj/projector-neotest",
				"kndndrj/projector-vscode",
				"kndndrj/projector-dbee",
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
						require("projector_dbee").OutputBuilder:new(),
					},
				})
			end,
		},
		{
			"kndndrj/projector-neotest",
			dependencies = {
				"nvim-neotest/neotest",
			},
		},
		{
			"kndndrj/projector-vscode",
		},
		{
			"kndndrj/projector-dbee",
		},
	})
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDDebugContinue, require("projector").continue },
	})
end

return L
