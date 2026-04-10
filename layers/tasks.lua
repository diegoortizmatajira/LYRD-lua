local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.Tasks: LYRD.setup.Module
local L = { name = "Tasks Runner" }

local function configure(filename)
	return function()
		-- check if the filename path exists, or create it otherwise, then open it
		if vim.fn.filereadable(filename) == 0 then
			vim.fn.mkdir(vim.fn.fnamemodify(filename, ":h"), "p")
			-- Create an empty file if it doesn't exist
			vim.fn.writefile({}, filename)
		end
		vim.cmd.edit(filename)
	end
end

--- @class TaskRequest
--- @field cmd string
--- @field args string[]
--- @field env table<string, string>?
--- @field cwd string?
--- @field name string
--- @field open_in_split boolean?
--- @field focus boolean?
--- @field auto_close boolean?
--- @field diagnostics_parser table?

--- Runs a task in a terminal
--- @param opts TaskRequest
function L.run_task(opts)
	-- Use overseer.nvim to run the command and show output in a terminal window
	local overseer = require("overseer")
	local components = { "default" }
	if opts.diagnostics_parser then
		table.insert(components, 1, {
			"on_output_parse",
			parser = {
				diagnostics = {
					opts.diagnostics_parser,
				},
			},
		})
		table.insert(components, 2, {
			"on_result_diagnostics_quickfix",
			open = true,
			close = true,
		})
	end
	if opts.open_in_split then
		table.insert(components, 1, {
			"open_output",
			direction = "dock",
			focus = opts.focus or false,
			on_complete = "always",
		})
	end
	local task = overseer.new_task({
		cmd = opts.cmd,
		args = opts.args,
		env = opts.env,
		cwd = opts.cwd,
		name = opts.name,
		strategy = "terminal",
		components = components,
	})
	if opts.auto_close then
		task:subscribe("on_complete", function()
			require("overseer.window").close()
			return false
		end)
	end
	task:start()
end

function L.plugins()
	setup.plugin({
		{
			"stevearc/overseer.nvim",
			version = "1",
			opts = {
				templates = {
					"builtin",
				},
				component_aliases = {
					default = {
						{
							"display_duration",
							detail_level = 2,
						},
						"on_output_summarize",
						"on_exit_set_status",
						{
							"on_complete_notify",
							system = "unfocused",
						},
						{
							"on_complete_dispose",
							timeout = 300,
						},
						{
							"open_output",
							direction = "dock",
							focus = true,
							on_complete = "always",
						},
					},
				},
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
					-- Set keymap to false to remove default behavior
					-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
					bindings = {
						["?"] = "ShowHelp",
						["g?"] = "ShowHelp",
						["<CR>"] = "RunAction",
						["<C-e>"] = "Edit",
						["o"] = "Open",
						["<C-v>"] = "OpenVsplit",
						["<C-s>"] = "OpenSplit",
						["<C-f>"] = "OpenFloat",
						["<C-q>"] = "OpenQuickFix",
						["p"] = "TogglePreview",
						["<C-l>"] = false,
						["<C-h>"] = false,
						["<C-o>"] = "IncreaseDetail",
						["<C-y>"] = "DecreaseDetail",
						["L"] = "IncreaseAllDetail",
						["H"] = "DecreaseAllDetail",
						["["] = "DecreaseWidth",
						["]"] = "IncreaseWidth",
						["{"] = "PrevTask",
						["}"] = "NextTask",
						["<C-k>"] = false,
						["<C-j>"] = false,
						["<C-u>"] = "ScrollOutputUp",
						["<C-i>"] = "ScrollOutputDown",
						["q"] = "Close",
					},
				},
				dap = false,
			},
		},
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDTasksToggle, ":OverseerToggle" },
		{ cmd.LYRDTasksRun, ":OverseerRun" },
		{ cmd.LYRDTasksConfigure, configure("./.vscode/tasks.json") },
		{ cmd.LYRDTasksConfigureLaunch, configure("./.vscode/launch.json") },
	})
end

return L
