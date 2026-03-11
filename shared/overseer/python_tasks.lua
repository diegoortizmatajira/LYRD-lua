---@param opts overseer.SearchParams
---@return nil|string
local function get_file(filename, opts)
	return vim.fs.find(filename, { upward = true, type = "file", path = opts.dir })[1]
end

local function task_template(name, command, check_for)
	---@type overseer.TemplateDefinition
	return {
		name = name,
		priority = 60,
		params = {
			---@type overseer.ListParam
			args = { optional = true, type = "list", delimiter = " " },
		},
		condition = {
			callback = function(opts)
				if vim.fn.executable(command[1]) == 0 then
					return false, string.format('Command "%s" not found', command[1])
				end
				if check_for then
					return get_file(check_for, opts) ~= nil
				end
				return true
			end,
		},
		builder = function(params)
			---@type overseer.TaskDefinition
			local task = { cmd = command, cwd = params.dir }

			if params.args then
				task.args = params.args
			end
			return task
		end,
	}
end

---@type overseer.TemplateFileProvider
return {
	name = "Python tasks",
	cache_key = function(search)
		return search.dir
	end,
	generator = function(_, cb)
		local task_templates = {
			task_template(
				"Pip install requirements",
				{ "pip", "install", "-r", "requirements.txt" },
				"requirements.txt"
			),
		}
		if vim.fn.executable("uv") == 1 then
			local tasks = {
				"uv sync",
				"uv build",
				"uv publish",
				"uv run pytest",
				"uv run pytest --cov",
			}
			for _, task_name in ipairs(tasks) do
				task_templates[#task_templates + 1] =
					task_template(task_name, vim.split(task_name, " "), "pyproject.toml")
			end
		end
		cb(task_templates)
	end,
}
