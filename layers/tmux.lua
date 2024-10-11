local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Tmux" }

function L.plugins(s)
	setup.plugin(s, { "christoomey/vim-tmux-navigator" })
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDPaneNavigateLeft, ":TmuxNavigateLeft" },
		{ cmd.LYRDPaneNavigateRight, ":TmuxNavigateRight" },
		{ cmd.LYRDPaneNavigateUp, ":TmuxNavigateUp" },
		{ cmd.LYRDPaneNavigateDown, ":TmuxNavigateDown" },
	})
end

return L
