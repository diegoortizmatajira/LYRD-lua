local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Debug" }

function L.plugins(s)
	setup.plugin(s, {
		"pocco81/dap-buddy.nvim",
		"mfussenegger/nvim-dap",
		{
			"rcarriga/nvim-dap-ui",
			init = function()
				vim.g.dap_virtual_text = true
			end,
			opts = {},
			dependencies = {
				"mfussenegger/nvim-dap",
				"nvim-neotest/nvim-nio",
			},
		},
		{
			"nvim-telescope/telescope-dap.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("dap")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		"theHamsta/nvim-dap-virtual-text",
	})
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDDebugBreakpoint, ":DapToggleBreakpoint" },
		{ cmd.LYRDDebugContinue, ":DapContinue" },
		{ cmd.LYRDDebugStepInto, ":DapStepInto" },
		{ cmd.LYRDDebugStepOver, ":DapStepOver" },
		{ cmd.LYRDDebugStop, ":DapTerminate" },
		{ cmd.LYRDDebugToggleUI, require("dapui").toggle },
		{ cmd.LYRDDebugToggleRepl, ":DapToggleRepl" },
	})
end

function L.keybindings(_) end

function L.complete(_) end

return L
