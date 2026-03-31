local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

---@class LYRD.layer.Debug: LYRD.setup.Module
local L = { 
    name = "Debugger",
    unskippable = true,
}

function L.plugins()
	setup.plugin({
		{
			"mfussenegger/nvim-dap",
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")
				dap.set_log_level("info")
				dap.listeners.before.attach.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.launch.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated.dapui_config = function()
					dapui.close()
				end
				dap.listeners.before.event_exited.dapui_config = function()
					dapui.close()
				end
				require("overseer").enable_dap()
			end,
			dependencies = {
				"stevearc/overseer.nvim",
			},
		},
		{
			"rcarriga/nvim-dap-ui",
			opts = {
				expand_lines = false,
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
						disconnect = icons.debug.disconnect,
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
							{ id = "scopes", size = 0.5 },
							{ id = "watches", size = 0.5 },
						},
						size = 0.27,
						position = "bottom",
					},
					{
						elements = {
							{ id = "stacks", size = 0.2 },
							{ id = "breakpoints", size = 0.2 },
							{ id = "repl", size = 0.1 },
							{ id = "console", size = 0.5 },
						},
						size = 0.33,
						position = "right",
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
	})
end

function L.is_running()
	local dap = require("dap")
	return dap.status() ~= ""
end

function L.start_handler(implementation)
	return function()
		if L.is_running() then
			local dap = require("dap")
			dap.listeners.after.event_terminated["lyrd_restart"] = function()
				dap.listeners.after.event_terminated["lyrd_restart"] = nil
				commands.execute_implementation(implementation)
			end
			commands.execute_implementation(cmd.LYRDDebugStop)
		else
			commands.execute_implementation(implementation)
		end
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
		{ cmd.LYRDDebugToggleUI, function() require("dapui").toggle() end },
		{ cmd.LYRDDebugToggleRepl, ":DapToggleRepl" },
	})
end

return L
