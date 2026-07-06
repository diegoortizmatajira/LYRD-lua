--- Environment variable used to locate the Hybris installation.
local HYBRIS_HOME_ENV = "HYBRIS_HOME"

local is_windows = vim.fn.has("win32") == 1
local server_script = is_windows and "hybrisserver.bat" or "hybrisserver.sh"
local ant_script = is_windows and "ant.bat" or "ant"

-- Returns the hybris installation root (the directory that contains bin/platform/).
-- HYBRIS_HOME may point to the project root (which has a hybris/ subfolder) or
-- directly to the hybris/ directory — both conventions are handled.
---@return string?
local function find_hybris_home()
	local raw = os.getenv(HYBRIS_HOME_ENV)
	if not raw or raw == "" then
		return nil
	end
	if vim.fn.isdirectory(raw .. "/bin/platform") == 1 then
		return raw
	end
	local with_sub = raw .. "/hybris"
	if vim.fn.isdirectory(with_sub .. "/bin/platform") == 1 then
		return with_sub
	end
	return nil
end

-- Resolves the Hybris home for this search, but only when the searched
-- directory is actually inside the Hybris project (either under the resolved
-- hybris/ folder or under the raw HYBRIS_HOME value, e.g. the project root).
---@param opts overseer.SearchParams
---@return string?
local function find_home_for_search(opts)
	local hybris_home = find_hybris_home()
	if not hybris_home then
		return nil
	end
	local dir = vim.fn.fnamemodify(opts.dir, ":p")
	local raw = os.getenv(HYBRIS_HOME_ENV)
	for _, candidate in ipairs({ hybris_home, raw }) do
		if candidate then
			local resolved = vim.fn.fnamemodify(candidate, ":p")
			if dir:sub(1, #resolved) == resolved then
				return hybris_home
			end
		end
	end
	return nil
end

local function task_template(name, command, cwd)
	---@type overseer.TemplateDefinition
	return {
		name = name,
		priority = 60,
		params = {
			---@type overseer.ListParam
			args = { optional = true, type = "list", delimiter = " " },
		},
		builder = function(params)
			---@type overseer.TaskDefinition
			local task = { cmd = vim.deepcopy(command), cwd = cwd }
			if params.args and #params.args > 0 then
				task.args = params.args
			end
			return task
		end,
	}
end

---@param platform_dir string
---@return string?, string?
local function resolve_ant_command(platform_dir)
	local local_ant = platform_dir .. "/" .. ant_script
	if vim.fn.filereadable(local_ant) == 1 then
		return local_ant
	end
	if vim.fn.executable("ant") == 1 then
		return "ant"
	end
	return nil, string.format('Ant command not found. Expected "%s" or global "ant" in PATH', local_ant)
end

---@type overseer.TemplateFileProvider
return {
	name = "Hybris (SAP Commerce) tasks",
	cache_key = function(search)
		return find_home_for_search(search) or search.dir
	end,
	condition = {
		callback = function(search)
			if not find_home_for_search(search) then
				return false, "HYBRIS_HOME is not set or current directory is outside the Hybris project"
			end
			return true
		end,
	},
	generator = function(opts, cb)
		local hybris_home = find_home_for_search(opts)
		if not hybris_home then
			cb({})
			return
		end
		local platform_dir = hybris_home .. "/bin/platform"
		local server = platform_dir .. "/" .. server_script
		local ant, ant_error = resolve_ant_command(platform_dir)
		if not ant then
			vim.schedule(function()
				vim.notify(ant_error, vim.log.levels.ERROR)
			end)
			cb({})
			return
		end

		cb({
			task_template("Hybris: Start server", { server, "start" }, platform_dir),
			task_template("Hybris: Stop server", { server, "stop" }, platform_dir),
			task_template("Hybris: Debug server", { server, "debug" }, platform_dir),
			task_template("Hybris: All", { ant, "all" }, platform_dir),
			task_template("Hybris: Build", { ant, "build" }, platform_dir),
			task_template("Hybris: Clean", { ant, "clean" }, platform_dir),
			task_template("Hybris: Clean all", { ant, "clean", "all" }, platform_dir),
			task_template("Hybris: Update system", { ant, "updatesystem" }, platform_dir),
			task_template("Hybris: Ant (custom target)", { ant }, platform_dir),
		})
	end,
}
