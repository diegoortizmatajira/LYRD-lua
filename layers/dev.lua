local setup = require("LYRD.setup")

---@class LYRD.layer.Development: LYRD.setup.Module
local L = { name = "Development Tools" }

function L.plugins()
	setup.plugin({
		{
			-- Adds support for commenting code with TODOs, FIXMEs, etc.
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
		},
		{
			-- Adds support for viewing colors in color values in the editor
			"norcalli/nvim-colorizer.lua",
		},
		{
			"ellisonleao/dotenv.nvim",
			opts = {},
			cmd = { "Dotenv", "DotenvGet" },
		},
		{
			"jesseleite/nvim-macroni",
			lazy = false,
			opts = {
				-- All of your `setup(opts)` and saved macros will go here
			},
		},
		{
			"chentoast/marks.nvim",
			event = "VeryLazy",
			opts = {},
		},
	})
end

local function run_local_server(port, folder)
	local command = "live-server"
	if vim.fn.executable(command) == 0 then
		vim.notify(
			"live-server is not installed. Please install it globally using 'npm i -g live-server'",
			vim.log.levels.ERROR
		)
		return
	end
	local tasks = require("LYRD.layers.tasks")
	tasks.run_task({
		name = string.format("Developer Local Server (port: %s)", port),
		cmd = command,
		args = {
			string.format("--port=%s", port),
			folder,
		},
		open_in_split = true,
		focus = true,
	})
end

function L.StartDevServer()
	vim.ui.input({ prompt = "Enter port number:", default = "3000" }, function(port)
		local current_dir = vim.fn.getcwd()
		vim.ui.input(
			{ prompt = "Folder to serve (leave blank for current directory):", default = current_dir },
			function(folder)
				-- Check if the provided folder is valid
				if folder == "" then
					folder = current_dir
				elseif not vim.fn.isdirectory(folder) then
					vim.notify("Invalid folder path: " .. folder, vim.log.levels.ERROR)
					return
				end
				run_local_server(port, folder)
			end
		)
	end)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement("*", {
		{ cmd.LYRDDevServerStart, L.StartDevServer },
		{
			cmd.LYRDSearchMacros,
			function()
				require("telescope").extensions.macroni.saved_macros()
			end,
		},
	})
end

return L
