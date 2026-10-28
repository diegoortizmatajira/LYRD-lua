local log = require("overseer.log")
local overseer = require("overseer")

local script_file = "build.sh"
if vim.fn.has("win32") == 1 then
	script_file = "build.ps1"
end

-- The script may lack a shebang (e.g. a bare `dotnet run` one-liner), which
-- makes direct execution fail with "exec format error", so go through a shell.
---@param script_path string
---@param ... string
---@return string[]
local function script_command(script_path, ...)
	local cmd = { "sh", script_path }
	if vim.fn.has("win32") == 1 then
		cmd = { "pwsh", "-File", script_path }
	end
	vim.list_extend(cmd, { ... })
	return cmd
end

---@param opts overseer.SearchParams
---@return nil|string
local function get_cake_script(opts)
	-- If windows os, check for "build.ps1" script
	return vim.fs.find(script_file, { upward = true, type = "file", path = opts.dir })[1]
end

local function task_template(script_path, cwd)
	---@type overseer.TemplateDefinition
	return {
		name = "Cake Frosting",
		priority = 60,
		params = {
			---@type overseer.StringParam
			target = { optional = false, type = "string", desc = "target" },
			---@type overseer.ListParam
			args = { optional = true, type = "list", delimiter = " " },
		},
		builder = function(params)
			local cmd = script_command(script_path)
			if params.target then
				table.insert(cmd, "-t")
				table.insert(cmd, params.target)
			end

			---@type overseer.TaskDefinition
			local task = { cmd = cmd, cwd = cwd }

			if params.args then
				task.args = params.args
			end
			return task
		end,
	}
end
---@type overseer.TemplateFileProvider
local provider = {
	name = "Cake Frosting",
	cache_key = function(search)
		return get_cake_script(search) or search.dir
	end,
	condition = {
		callback = function(search)
			if vim.fn.executable("dotnet") == 0 then
				return false, 'Command "dotnet" not found'
			end
			if not (get_cake_script(search)) then
				return false, "No cake frosting script found"
			end
			return true
		end,
	},
	generator = function(opts, cb)
		local ret = {}
		local script_path = get_cake_script(opts)
		if script_path == nil then
			log:error("No cake frosting script found in %s", opts.dir)
			cb(ret)
			return
		end
		local cwd = script_path ~= nil and vim.fs.dirname(script_path) or opts.dir
		local template = task_template(script_path, cwd)
		local jid = vim.fn.jobstart(script_command(script_path, "--description"), {
			cwd = cwd,
			stdout_buffered = true,
			on_stdout = vim.schedule_wrap(function(_, output)
				-- Everything up to the "=====" separator is build noise (warnings, header)
				local in_table = false
				for _, line in ipairs(output) do
					if not in_table then
						in_table = line:match("^=+%s*$") ~= nil
					elseif #line > 0 then
						local task_name, description = line:match("^(%w+)%s*(.*)")
						if task_name ~= nil then
							local override = {
								name = string.format("cake: %s", task_name),
								desc = #description > 0 and description or nil,
							}
							table.insert(ret, overseer.wrap_template(template, override, { target = task_name }))
						end
					end
				end
				cb(ret)
			end),
		})
		if jid == 0 then
			log:error("Passed invalid arguments to cake frosting script")
			cb(ret)
		elseif jid == -1 then
			log:error("cake frosting script is not executable")
			cb(ret)
		end
	end,
}

return provider
