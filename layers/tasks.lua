local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Tasks" }

local function configure(filename)
	return function()
		-- check if the filename path exists, or create it otherwise, then open it
		if vim.fn.filereadable(filename) == 0 then
			vim.fn.mkdir(vim.fn.fnamemodify(filename, ":h"), "p")
			-- Create an empty file if it doesn't exist
			vim.fn.writefile({}, filename)
		end
		vim.cmd("edit " .. filename)
	end
end
function L.plugins()
	setup.plugin({
		{
			--TODO: Make the most out of this one
			"stevearc/overseer.nvim",
			opts = {
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
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
