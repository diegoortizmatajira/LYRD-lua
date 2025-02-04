local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Tmux" }

function L.plugins()
	setup.plugin({
		{
			"christoomey/vim-tmux-navigator",
		},
		{
			"mrjones2014/smart-splits.nvim",
			opts = {},
		},
	})
end

function L.settings()
	vim.g.tmux_navigator_no_wrap = 1
	commands.implement("*", {
		{ cmd.LYRDPaneNavigateLeft, ":TmuxNavigateLeft" },
		{ cmd.LYRDPaneNavigateRight, ":TmuxNavigateRight" },
		{ cmd.LYRDPaneNavigateUp, ":TmuxNavigateUp" },
		{ cmd.LYRDPaneNavigateDown, ":TmuxNavigateDown" },

		{ cmd.LYRDPaneResizeLeft, ":SmartResizeLeft" },
		{ cmd.LYRDPaneResizeRight, ":SmartResizeRight" },
		{ cmd.LYRDPaneResizeUp, ":SmartResizeUp" },
		{ cmd.LYRDPaneResizeDown, ":SmartResizeDown" },

		{ cmd.LYRDPaneSwapLeft, ":SmartSwapLeft" },
		{ cmd.LYRDPaneSwapRight, ":SmartSwapRight" },
		{ cmd.LYRDPaneSwapUp, ":SmartSwapUp" },
		{ cmd.LYRDPaneSwapDown, ":SmartSwapDown" },
	})
end

return L
