local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Tmux" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"christoomey/vim-tmux-navigator",
			cmd = {
				"TmuxNavigateLeft",
				"TmuxNavigateDown",
				"TmuxNavigateUp",
				"TmuxNavigateRight",
				"TmuxNavigatePrevious",
			},
		},
	})
end

function L.settings(s)
	vim.g.tmux_navigator_no_wrap = 1
	commands.implement(s, "*", {
		{ cmd.LYRDPaneNavigateLeft, ":TmuxNavigateLeft" },
		{ cmd.LYRDPaneNavigateRight, ":TmuxNavigateRight" },
		{ cmd.LYRDPaneNavigateUp, ":TmuxNavigateUp" },
		{ cmd.LYRDPaneNavigateDown, ":TmuxNavigateDown" },
	})
end

return L
