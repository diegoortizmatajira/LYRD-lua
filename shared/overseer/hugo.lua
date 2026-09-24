local hugo_site = require("LYRD.shared.site-providers.hugo")

local function task_template(name, command)
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
				return hugo_site.find_config_file(opts.dir) ~= nil
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
	name = "Hugo tasks",
	cache_key = function(search)
		return search.dir
	end,
	generator = function(_, cb)
		cb({
			task_template("Hugo (draft server)", { "hugo", "server", "--buildDrafts" }),
		})
	end,
}
