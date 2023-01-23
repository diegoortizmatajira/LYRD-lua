local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "Debug" }

function L.plugins(s)
	setup.plugin(s, {
		"Pocco81/DAPInstall.nvim",
		"mfussenegger/nvim-dap",
		{ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } },
		"nvim-telescope/telescope-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
	})
end

function L.settings(s)
	require("dapui").setup()
	vim.g.dap_virtual_text = true
	commands.implement(s, "*", {
		LYRDDebugBreakpoint = ":DapToggleBreakpoint",
		LYRDDebugContinue = ":DapContinue",
		LYRDDebugStepInto = ":DapStepInto",
		LYRDDebugStepOver = ":DapStepOver",
		LYRDDebugStop = ":DapTerminate",
		LYRDDebugToggleUI = require("dapui").toggle,
		LYRDDebugToggleREPL = ":DapToggleRepl",
	})
end

function L.keybindings(_) end

function L.complete(_)
	require("telescope").load_extension("dap")
end

return L
