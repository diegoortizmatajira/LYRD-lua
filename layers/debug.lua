local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Debug" }

function L.plugins()
	setup.plugin({
		{
			"pocco81/dap-buddy.nvim",
		},
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
					expanded = icons.chevron.down,
					collapsed = icons.chevron.right,
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
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
		-- {
		-- 	--TODO: Add configuration https://github.com/niuiic/dap-utils.nvim
		-- 	"niuiic/dap-utils.nvim",
		-- },
	})
end

function L.is_running()
	local dap = require("dap")
	return dap.status() ~= ""
end

function L.start_handler(implementation)
	return function()
		if L.is_running() then
			commands.execute_implementation(cmd.LYRDDebugStop)
		end
		commands.execute_implementation(implementation)
	end
end

function L.continue_handler(implementation)
	return function()
		if L.is_running() then
			commands.execute_implementation(implementation)
		else
			commands.execute_implementation(cmd.LYRDDebugStart)
		end
	end
end

function L.settings()
	vim.fn.sign_define("DapBreakpoint", {
		text = icons.debug.breakpoint,
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	})
	vim.fn.sign_define("DapBreakpointRejected", {
		text = icons.debug.breakpoint,
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	})
	vim.fn.sign_define("DapStopped", {
		text = icons.debug.current_line,
		texthl = "DiagnosticSignWarn",
		linehl = "Visual",
		numhl = "DiagnosticSignWarn",
	})

	commands.implement("*", {
		{ cmd.LYRDDebugBreakpoint, ":DapToggleBreakpoint" },
		{ cmd.LYRDDebugStart, L.start_handler(":DapContinue") },
		{ cmd.LYRDDebugContinue, L.continue_handler(":DapContinue") },
		{ cmd.LYRDDebugStepInto, ":DapStepInto" },
		{ cmd.LYRDDebugStepOut, ":DapStepOut" },
		{ cmd.LYRDDebugStepOver, ":DapStepOver" },
		{ cmd.LYRDDebugStop, ":DapTerminate" },
		{ cmd.LYRDDebugToggleUI, require("dapui").toggle },
		{ cmd.LYRDDebugToggleRepl, ":DapToggleRepl" },
	})
end

return L
