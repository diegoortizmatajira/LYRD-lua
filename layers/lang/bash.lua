local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Bash Scripting",
	required_mason_packages = {
		"bashls",
		"shfmt",
		"shellcheck", -- ShellCheck is used by bashls for diagnostics, so we include it as a required Mason package.
	},
	required_enabled_lsp_servers = {
		"bashls",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "sh",
			format_settings = { "shfmt" },
		},
	},
}

local function script_run_task(script_path)
	local tasks = require("LYRD.layers.tasks")
	--- get the current working directory as the folder where the current file is located
	local cwd = vim.fn.expand("%:p:h")

	tasks.run_task({
		name = "Script: " .. vim.fn.fnamemodify(script_path, ":t"),
		cmd = "bash",
		args = { "-c", script_path },
		cwd = cwd,
		open_in_split = true,
		focus = true,
	})
end

function L.run_current_script()
	local filetype = vim.bo.filetype
	if filetype ~= "sh" then
		vim.notify("Current buffer is not a shell script.", vim.log.levels.ERROR)
		return
	end

	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		vim.notify("Current buffer has no file path. Please save the script first.", vim.log.levels.ERROR)
		return
	end
	script_run_task(file_path)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	-- Command implementations
	commands.implement("sh", {
		{ cmd.LYRDCodeRun, L.run_current_script },
	})
end

return declarative_layer.apply(L)
