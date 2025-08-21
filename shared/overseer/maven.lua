local log = require("overseer.log")
local overseer = require("overseer")

local maven_wrapper = "mvnw"

---@param opts overseer.SearchParams
---@return nil|string
local function get_pom(opts)
	-- If windows os, check for "build.ps1" script
	return vim.fs.find("pom.xml", { upward = true, type = "file", path = opts.dir })[1]
end

---@param opts overseer.SearchParams
---@return nil|string
local function get_mvnw(opts)
	return vim.fs.find(maven_wrapper, { upward = true, type = "file", path = opts.dir })[1]
end

local function task_template(maven_cmd, cwd)
	---@type overseer.TemplateDefinition
	return {
		name = "Maven",
		priority = 60,
		params = {
			---@type overseer.ListParam
			args = { optional = true, type = "list", delimiter = " " },
		},
		builder = function(params)
			local cmd = { maven_cmd }

			---@type overseer.TaskDefinition
			local task = { cmd = cmd, cwd = cwd }

			if params.args then
				task.args = params.args
			end
			return task
		end,
	}
end

local function task_with_params(maven_cmd, cwd)
	---@type overseer.TemplateDefinition
	return {
		name = "maven (with custom params)",
		priority = 60,
		builder = function(params)
			local cmd = { maven_cmd }

			---@type overseer.TaskDefinition
			local task = { cmd = cmd, cwd = cwd }

			local mvn_params = vim.fn.input("Maven params: ")
			if mvn_params then
				task.args = vim.split(mvn_params, " ", { trimempty = true })
			end
			return task
		end,
	}
end
---@type overseer.TemplateFileProvider
local provider = {
	name = "Maven",
	cache_key = function(search)
		return get_pom(search) or search.dir
	end,
	condition = {
		callback = function(search)
			if not get_mvnw(search) then
				return false, "Maven command not found"
			end
			if not (get_pom(search)) then
				return false, "No pom.xml file found"
			end
			return true
		end,
	},
	generator = function(opts, cb)
		local pom_path = get_pom(opts)
		local maven_cmd = get_mvnw(opts) or maven_wrapper
		local cwd = pom_path ~= nil and vim.fs.dirname(pom_path) or opts.dir
		local ret = {}
		-- Adds a task to run Maven with custom parameters
		table.insert(ret, task_with_params(maven_cmd, cwd))
		-- Adds multiple default tasks for common Maven actions
		local actions = {
			"clean compile",
			"clean test",
			"clean",
			"compile",
			"deploy",
			"install",
			"package",
			"site",
			"test",
			"validate",
			"verify",
		}
		local template = task_template(maven_cmd, cwd)
		for _, action in ipairs(actions) do
			local override = {
				name = string.format("maven: %s", action),
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
