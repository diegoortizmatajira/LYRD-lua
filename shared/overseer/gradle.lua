local overseer = require("overseer")

local gradle_default = "gradle"
local gradle_wrapper = "gradlew"

---@param opts overseer.SearchParams
---@return nil|string
local function get_settings_gradle(opts)
	-- If windows os, check for "build.ps1" script
	return vim.fs.find("settings.gradle", { upward = true, type = "file", path = opts.dir })[1]
end

---@param opts overseer.SearchParams
---@return nil|string
local function get_gradlew(opts)
	return vim.fs.find(gradle_wrapper, { upward = true, type = "file", path = opts.dir })[1]
end

local function task_template(gradle_cmd, cwd)
	---@type overseer.TemplateDefinition
	return {
		name = "Gradle",
		priority = 60,
		params = {
			---@type overseer.ListParam
			args = { optional = true, type = "list", delimiter = " " },
		},
		builder = function(params)
			local cmd = { gradle_cmd }
			local env = {}
			local java_home = os.getenv("JAVA_HOME")
			if java_home then
				-- If JAVA_HOME is set in the environment, pass it to the task environment
				env.JAVA_HOME = java_home
			end

			---@type overseer.TaskDefinition
			local task = {
				cmd = cmd,
				cwd = cwd,
				env = env,
			}

			if params.args then
				task.args = params.args
			end
			return task
		end,
	}
end

local function task_with_params(gradle_cmd, cwd)
	---@type overseer.TemplateDefinition
	return {
		name = "Gradle (with custom params)",
		priority = 60,
		params = {
			parameters = {
				name = "Parameters",
				desc = "List of parameters for Gradle",
				long_desc = "A list of parameters to pass to the Gradle command. Separate multiple parameters with spaces.",
				type = "list",
				subtype = {
					type = "string",
				},
				delimiter = " ",
			},
		},
		builder = function(params)
			local cmd = { gradle_cmd }

			---@type overseer.TaskDefinition
			local task = { cmd = cmd, cwd = cwd }

			if params and params.parameters then
				task.args = params.parameters
			end
			return task
		end,
	}
end
---@type overseer.TemplateFileProvider
local provider = {
	name = "Gradle",
	cache_key = function(search)
		return get_settings_gradle(search) or search.dir
	end,
	condition = {
		callback = function(search)
			if not get_gradlew(search) and not vim.fn.executable(gradle_default) then
				return false, "Gradle command not found"
			end
			if not (get_settings_gradle(search)) then
				return false, "No settings.gradle file found"
			end
			return true
		end,
	},
	generator = function(opts, cb)
		local pom_path = get_settings_gradle(opts)
		local gradle_cmd = get_gradlew(opts) or gradle_default
		local cwd = pom_path ~= nil and vim.fs.dirname(pom_path) or opts.dir
		local ret = {}
		-- Adds a task to run Gradle with custom parameters
		table.insert(ret, task_with_params(gradle_cmd, cwd))
		-- Adds multiple default tasks for common Gradle actions
		local actions = {
			"build",
			"clean build",
			"clean test",
			"clean",
			"distTar",
			"distZip",
			"installDist",
			"test",
		}
		local template = task_template(gradle_cmd, cwd)
		for _, action in ipairs(actions) do
			local override = {
				name = string.format("Gradle: %s", action),
			}
			table.insert(
				ret,
				overseer.wrap_template(template, override, { args = vim.split(action, " ", { trimempty = true }) })
			)
		end
		cb(ret)
	end,
}

return provider
