local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Shell Scripting (sh, bash, zsh, fish)",
	required_mason_packages = {
		"bashls",
		"fish-lsp",
		"shfmt",
		"shellcheck", -- ShellCheck is used by bashls for diagnostics, so we include it as a required Mason package.
	},
	required_enabled_lsp_servers = {
		"bashls",
		"fish_lsp",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = "sh",
			format_settings = { "shfmt" },
		},
		{
			target_filetype = "fish",
			format_settings = { "fish_indent" },
		},
	},
	required_treesitter_parsers = {
		"bash",
		"fish",
		"zsh",
	},
	required_executables = {
		"fish",
	},
}

--- Maps a shell filetype to the interpreter used to run scripts of that type.
local shell_interpreter_per_filetype = {
	sh = "bash",
	fish = "fish",
}

local function script_run_task(script_path, interpreter)
	local tasks = require("LYRD.layers.tasks")
	--- get the current working directory as the folder where the current file is located
	local cwd = vim.fn.expand("%:p:h")

	tasks.run_task({
		name = "Script: " .. vim.fn.fnamemodify(script_path, ":t"),
		cmd = interpreter,
		args = { "-c", script_path },
		cwd = cwd,
		open_in_split = true,
		focus = true,
	})
end

function L.run_current_script()
	local filetype = vim.bo.filetype
	local interpreter = shell_interpreter_per_filetype[filetype]
	if not interpreter then
		vim.notify("Current buffer is not a shell script.", vim.log.levels.ERROR)
		return
	end

	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		vim.notify("Current buffer has no file path. Please save the script first.", vim.log.levels.ERROR)
		return
	end
	script_run_task(file_path, interpreter)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	-- Command implementations
	commands.implement({ "sh", "fish" }, {
		{ cmd.LYRDCodeRun, L.run_current_script },
	})
end

return declarative_layer.apply(L)
