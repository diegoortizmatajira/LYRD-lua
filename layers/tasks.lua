local commands = require("LYRD.layers.commands")
local setup = require("LYRD.shared.setup")
local cmd = require("LYRD.layers.lyrd-commands").cmd

-- overseer.strategy.load() does `require("overseer.strategy.<name>")` -- there's
-- no registration API, so the "tmux" strategy name is made resolvable by
-- preloading it here, before overseer.nvim (or any task using strategy =
-- "tmux") is ever loaded.
package.preload["overseer.strategy.tmux"] = function()
	return require("LYRD.shared.overseer.tmux_strategy")
end

---@class LYRD.layer.Tasks: LYRD.shared.setup.Module
local L = { name = "Tasks Runner" }

--- Deterministic per-workspace name for the overseer task bundle that holds
--- this cwd's tmux-strategy tasks, so it can be found again on a later
--- Neovim startup in the same directory.
--- @param cwd string
--- @return string
local function tmux_bundle_name(cwd)
	return "lyrd-tasks-" .. vim.fn.sha256(cwd):sub(1, 16)
end

--- @param task overseer.Task
--- @param cwd string
--- @return boolean
local function is_tmux_task_for_cwd(task, cwd)
	return task.cwd == cwd and task.strategy ~= nil and task.strategy.name == "tmux"
end

--- Saves the current cwd's tmux-strategy tasks into its overseer task bundle,
--- so they can be recovered (reattached to) on a later Neovim startup. Only
--- tmux-strategy tasks are included: a "terminal"-strategy task's process is
--- always dead by the time Neovim restarts, so silently re-running it would
--- be surprising (a one-shot build/test task should never auto-run again).
--- @param cwd string
local function save_tmux_bundle(cwd)
	local overseer = require("overseer")
	local task_bundle = require("overseer.task_bundle")
	local name = tmux_bundle_name(cwd)
	local tasks = overseer.list_tasks({
		filter = function(task)
			return is_tmux_task_for_cwd(task, cwd)
		end,
	})
	if vim.tbl_isempty(tasks) then
		task_bundle.delete_task_bundle(name, { ignore_missing = true })
		return
	end
	task_bundle.save_task_bundle(name, tasks, { on_conflict = "overwrite" })
end

local tmux_bundle_save_timer = nil

--- Debounces save_tmux_bundle so rapid-fire task list updates (several
--- components dispatch on every status change) don't hammer the disk.
local function schedule_tmux_bundle_save()
	if tmux_bundle_save_timer then
		return
	end
	tmux_bundle_save_timer = vim.defer_fn(function()
		tmux_bundle_save_timer = nil
		save_tmux_bundle(vim.fn.getcwd())
	end, 500)
end

--- Loads (and autostarts) this cwd's saved tmux-strategy tasks, if any.
--- Because the tmux strategy's start() is idempotent (`tmux new-session
--- -A`), autostarting a loaded task definition reattaches to the
--- still-running session instead of spawning a duplicate -- this is what
--- makes a plain overseer task bundle into a working recovery mechanism.
--- @param cwd string
local function recover_tmux_bundle(cwd)
	if vim.fn.executable("tmux") == 0 then
		return
	end
	require("overseer.task_bundle").load_task_bundle(tmux_bundle_name(cwd), {
		autostart = true,
		ignore_missing = true,
	})
end

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
--- @field max_lines number?
--- @field use_tmux boolean? Run in a detached tmux session instead of a Neovim-owned
--- terminal job, so the task survives closing the split or restarting Neovim, and can
--- be reattached to later (see shared/overseer/tmux_strategy.lua). Only for tasks that
--- don't rely on diagnostics_parser/parsed output -- the tmux strategy is opaque.

--- Runs a task in a terminal
--- @param opts TaskRequest
function L.run_task(opts)
	-- Use overseer.nvim to run the command and show output in a terminal window
	local overseer = require("overseer")
	local components = { "default" }
	local strategy = "terminal"
	if opts.use_tmux then
		if vim.fn.executable("tmux") == 1 then
			strategy = "tmux"
		else
			vim.notify(
				string.format("LYRD Tasks: tmux not found, falling back to terminal strategy for '%s'", opts.name),
				vim.log.levels.WARN
			)
		end
	end
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
		strategy = strategy,
		components = components,
		max_lines = opts.max_lines or 5000,
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
				task_defaults = {
					max_lines = 5000,
				},
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

	-- Keep the current workspace's tmux-task bundle up to date, regardless of
	-- how the task was started (L.run_task, or a template run via
	-- :OverseerRun, e.g. the Hybris server tasks in shared/overseer/hybris_tasks.lua).
	vim.api.nvim_create_autocmd("User", {
		pattern = "OverseerListUpdate",
		group = vim.api.nvim_create_augroup("LYRDTasksTmuxBundle", { clear = true }),
		callback = schedule_tmux_bundle_save,
	})
end

function L.complete()
	-- Deferred so it never blocks startup; safe to call even when no bundle
	-- exists yet (ignore_missing) or tmux isn't installed.
	vim.schedule(function()
		recover_tmux_bundle(vim.fn.getcwd())
	end)
end

return L
