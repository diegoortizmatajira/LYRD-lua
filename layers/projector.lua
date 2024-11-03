local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Projector" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"kndndrj/nvim-projector",
			requires = {
				-- required:
				"muniftanjim/nui.nvim",
				-- optional extensions:
				"kndndrj/projector-neotest",
				-- dependencies of extensions:
				"nvim-neotest/neotest",
			},
		},
		"kndndrj/projector-neotest",
		"kndndrj/projector-vscode",
		"kndndrj/projector-dbee",
	})
end

function L.settings(s)
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
	commands.implement(s, "*", {
		{ cmd.LYRDDebugContinue, require("projector").continue },
	})
end

return L
