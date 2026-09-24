local ok_util, util = pcall(require, "overseer.util")
assert(ok_util, "overseer.nvim is required for the tmux strategy")
local ok_shell, shell = pcall(require, "overseer.shell")
assert(ok_shell, "overseer.nvim is required for the tmux strategy")

-- Runs overseer tasks inside a detached tmux session instead of a
-- Neovim-owned job, so the process survives closing the split, or Neovim
-- itself. The session name is derived deterministically from the task's cwd
-- and name (not from the task's id, which is only unique within a single
-- Neovim process), so a later `start()` for "the same" task -- from a
-- restarted Neovim, or from an overseer task bundle loaded on startup --
-- reattaches via `tmux new-session -A` instead of spawning a duplicate.
--
-- This strategy is intentionally "opaque": it does not dispatch on_output
-- events, so components relying on parsed stdout (on_output_parse,
-- diagnostics/quickfix, on_output_summarize) will not receive anything.
-- It is meant for long-running, interactive-looking processes (dev servers,
-- watch builds) where a live terminal view and start/stop/exit-status are
-- all that's needed -- not for build/test tasks that need structured output.
--
-- Known limitation: if the tmux session is destroyed out-of-band (e.g. a
-- manual `tmux kill-session` from a real terminal, or a machine reboot)
-- while Neovim keeps running, the task has no way to notice and will keep
-- showing as RUNNING. Stopping the task from overseer itself (`stop()`)
-- does not have this problem, since overseer finalizes the task's status
-- before this strategy's `stop()` runs.

---@class LYRD.overseer.TmuxStrategy : overseer.Strategy
---@field bufnr nil|integer
---@field chan_id nil|integer
---@field session_id nil|string
---@field exit_job nil|integer
local TmuxStrategy = {}

local EXIT_STATUS_DIR = vim.fs.joinpath(vim.fn.stdpath("state"), "lyrd-overseer-tmux")

---@param task overseer.Task
---@return string
local function session_id_for(task)
	local seed = string.format("%s\0%s", task.cwd or "", task.name or "")
	return "lyrd-" .. vim.fn.sha256(seed):sub(1, 24)
end

---@param session_id string
---@return string
local function exit_status_file(session_id)
	return vim.fs.joinpath(EXIT_STATUS_DIR, session_id .. ".exit")
end

---@param task overseer.Task
---@return string
local function build_shell_cmd(task)
	if type(task.cmd) == "table" then
		local str_cmd = shell.escape_cmd(task.cmd, "strong", "bash")
		return str_cmd
	end
	return task.cmd
end

---@return overseer.Strategy
function TmuxStrategy.new()
	local strategy = {
		bufnr = nil,
		chan_id = nil,
		session_id = nil,
		exit_job = nil,
	}
	setmetatable(strategy, { __index = TmuxStrategy })
	---@type LYRD.overseer.TmuxStrategy
	return strategy
end

function TmuxStrategy:reset()
	util.soft_delete_buf(self.bufnr)
	self.bufnr = nil
	if self.chan_id then
		vim.fn.jobstop(self.chan_id)
		self.chan_id = nil
	end
	if self.exit_job then
		vim.fn.jobstop(self.exit_job)
		self.exit_job = nil
	end
end

function TmuxStrategy:get_bufnr()
	return self.bufnr
end

---@param task overseer.Task
function TmuxStrategy:start(task)
	vim.fn.mkdir(EXIT_STATUS_DIR, "p")
	self.session_id = session_id_for(task)
	local session_id = self.session_id
	local exit_file = exit_status_file(session_id)

	local wrapped = string.format(
		"%s; __lyrd_status=$?; printf '%%s' \"$__lyrd_status\" > %s; tmux wait-for -S %s-done",
		build_shell_cmd(task),
		vim.fn.shellescape(exit_file),
		session_id
	)

	-- `tmux new-session -A` behaves like `attach-session` (ignoring -c/-e/the
	-- trailing command entirely) when the session already exists, and
	-- attach-session needs a real controlling terminal -- it can't run as a
	-- plain non-pty subprocess (fails with "open terminal failed: not a
	-- terminal"). So, like sidekick.nvim's tmux backend, create-or-attach and
	-- the visible attach both happen as the SAME termopen'd command: creating
	-- a session shows its output live from the start, and reattaching to an
	-- existing one Just Works because this pty is a real controlling
	-- terminal.
	local tmux_cmd = { "tmux", "new-session", "-A", "-s", session_id, "-c", task.cwd }
	for key, value in pairs(task.env or {}) do
		vim.list_extend(tmux_cmd, { "-e", string.format("%s=%s", key, tostring(value)) })
	end
	vim.list_extend(tmux_cmd, { "sh", "-c", wrapped })

	self.bufnr = vim.api.nvim_create_buf(false, true)
	local mode = vim.api.nvim_get_mode().mode
	util.run_in_fullscreen_win(self.bufnr, function()
		self.chan_id = vim.fn.termopen(tmux_cmd)
	end)
	util.hack_around_termopen_autocmd(mode)

	if not self.chan_id or self.chan_id <= 0 then
		error(string.format("Failed to start/attach tmux session '%s'", session_id))
	end

	self.exit_job = vim.fn.jobstart({ "tmux", "wait-for", session_id .. "-done" }, {
		on_exit = function(_, wait_for_code)
			self.exit_job = nil
			-- `tmux wait-for` exits 0 only when genuinely signaled by the wrapped
			-- command finishing (`tmux wait-for -S`). A nonzero code means this
			-- job was killed instead (e.g. our own stop(), or Neovim shutting
			-- down) -- the real command may still be running, so don't finalize.
			if wait_for_code ~= 0 then
				return
			end
			-- Don't finalize while Neovim itself is exiting: we manually clean up
			-- via stop()/dispose() as needed, and don't want to trigger user code
			-- (components, subscribers) mid-shutdown. Mirrors overseer's own
			-- terminal strategy (strategy/terminal.lua).
			if vim.v.exiting ~= vim.NIL then
				return
			end
			local code = 0
			local ok, lines = pcall(vim.fn.readfile, exit_file)
			if ok and lines[1] and lines[1] ~= "" then
				code = tonumber(lines[1]) or 0
			end
			pcall(vim.fn.delete, exit_file)
			task:on_exit(code)
		end,
	})
end

function TmuxStrategy:stop()
	if not self.session_id then
		return
	end
	local session_id = self.session_id
	if self.exit_job then
		vim.fn.jobstop(self.exit_job)
		self.exit_job = nil
	end
	vim.system({ "tmux", "send-keys", "-t", session_id, "C-c" }, { text = true })
	vim.defer_fn(function()
		vim.system({ "tmux", "kill-session", "-t", session_id }, { text = true })
	end, 250)
end

-- Only tears down the Neovim-side attach buffer/job. Never kills the tmux
-- session: that must stay a deliberate `stop()`, not a side effect of
-- overseer disposing its own task object (e.g. the on_complete_dispose
-- component's timeout) -- otherwise a long-running server would die exactly
-- when we're trying to keep it alive.
function TmuxStrategy:dispose()
	if self.chan_id then
		vim.fn.jobstop(self.chan_id)
		self.chan_id = nil
	end
	if self.exit_job then
		vim.fn.jobstop(self.exit_job)
		self.exit_job = nil
	end
	util.soft_delete_buf(self.bufnr)
	self.bufnr = nil
end

return TmuxStrategy
