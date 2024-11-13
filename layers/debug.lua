local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Debug" }

function L.plugins(s)
	setup.plugin(s, {
		"pocco81/dap-buddy.nvim",
		{
			"mfussenegger/nvim-dap",
			config = function()
				local dap = require("dap")
				dap.set_log_level("info")
			end,
		},
		{
			"rcarriga/nvim-dap-ui",
			init = function()
				vim.g.dap_virtual_text = true
			end,
			opts = {
				icons = {
					expanded = icons.triangle.down,
					collapsed = icons.triangle.right,
					circular = icons.status.busy,
				},
				controls = {
					enabled = true,
					-- Display controls in this element
					element = "repl",
					icons = {
						pause = icons.debug.pause,
						play = icons.debug.play,
						step_into = icons.debug.step_into,
						step_over = icons.debug.step_over,
						step_out = icons.debug.step_out,
						step_back = icons.debug.step_back,
						run_last = icons.debug.run_last,
						terminate = icons.debug.terminate,
					},
				},
				mappings = {
					-- Use a table to apply multiple mappings
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.33 },
							{ id = "breakpoints", size = 0.17 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						size = 0.33,
						position = "right",
					},
					{
						elements = {
							{ id = "repl", size = 0.45 },
							{ id = "console", size = 0.55 },
						},
						size = 0.27,
						position = "bottom",
					},
				},
				floating = {
					max_height = 0.9,
					max_width = 0.5, -- Floats will be treated as percentage of your screen.
					border = "rounded",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
			},
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
	vim.fn.sign_define("DapBreakpoint", {
		text = "",
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	})
	vim.fn.sign_define("DapBreakpointRejected", {
		text = "",
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	})
	vim.fn.sign_define("DapStopped", {
		text = "",
		texthl = "DiagnosticSignWarn",
		linehl = "Visual",
		numhl = "DiagnosticSignWarn",
	})

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
