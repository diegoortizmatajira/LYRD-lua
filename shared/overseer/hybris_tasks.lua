local java_common = require("LYRD.shared.java-common")

--- Environment variable used to locate the Hybris installation.
local HYBRIS_HOME_ENV = "HYBRIS_HOME"

local is_windows = vim.fn.has("win32") == 1
local server_script = is_windows and "hybrisserver.bat" or "hybrisserver.sh"
local ant_script = is_windows and "ant.bat" or "ant"

-- Hybris' own build/runtime tooling (ant, hybrisserver.sh) requires Java 17,
-- independent of whatever JAVA_HOME happens to be exported for other tools in
-- this session -- e.g. jdtls is pinned to Java 21 to launch its own OSGi
-- server process (see runtime/lsp/jdtls.lua's resolve_launcher_java), and that
-- ambient JAVA_HOME would otherwise leak into these tasks and break the
-- Hybris build/server. Search java-common.lua's discovered runtimes (which
-- already picks up $JAVA17_HOME, sdkman, asdf, jenv, system JVM dirs, etc.)
-- for a matching JDK instead of trusting the ambient environment.
local HYBRIS_JAVA_VERSION = 17
local warned_missing_hybris_java = false

---@return string?
local function resolve_hybris_java_home()
	for _, runtime in ipairs(java_common.get_runtimes()) do
		if tonumber(runtime.name:match("JavaSE%-(%d+)")) == HYBRIS_JAVA_VERSION then
			return runtime.path
		end
	end
	if not warned_missing_hybris_java then
		warned_missing_hybris_java = true
		vim.schedule(function()
			vim.notify(
				string.format(
					"Hybris: no Java %d runtime found (checked $JAVA%d_HOME and sdkman/asdf/jenv/system JVM dirs). "
						.. "Falling back to the ambient JAVA_HOME/PATH, which may be the wrong version for "
						.. "Hybris' ant build/server.",
					HYBRIS_JAVA_VERSION,
					HYBRIS_JAVA_VERSION
				),
				vim.log.levels.WARN
			)
		end)
	end
	return nil
end

-- Env overrides applied to every Hybris task so ant/the server always run on
-- Java 17 regardless of the ambient JAVA_HOME (e.g. set to 21 for jdtls).
---@return table<string, string>
local function hybris_env()
	local java_home = resolve_hybris_java_home()
	if not java_home then
		return {}
	end
	local sep = is_windows and ";" or ":"
	return {
		JAVA_HOME = java_home,
		PATH = java_home .. "/bin" .. sep .. (os.getenv("PATH") or ""),
	}
end

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
			local task = { cmd = vim.deepcopy(command), cwd = cwd, env = hybris_env() }
			if params.args and #params.args > 0 then
				task.args = params.args
			end
			return task
		end,
	}
end

-- Like task_template, but pipes the command's output through a filter so only
-- matching lines reach the task's output buffer (e.g. the server's verbose
-- debug-mode logging would otherwise peg Neovim's terminal redraw for hours).
---@param filter string pattern passed to grep/findstr
local function filtered_task_template(name, command, cwd, filter)
	---@type overseer.TemplateDefinition
	return {
		name = name,
		priority = 60,
		params = {
			---@type overseer.ListParam
			args = { optional = true, type = "list", delimiter = " " },
		},
		builder = function(params)
			local parts = vim.deepcopy(command)
			if params.args and #params.args > 0 then
				vim.list_extend(parts, params.args)
			end
			---@type overseer.TaskDefinition
			local task
			if is_windows then
				local quoted = vim.tbl_map(function(p)
					return string.format('"%s"', p)
				end, parts)
				task = {
					cmd = { "cmd.exe", "/c", table.concat(quoted, " ") .. ' | findstr /C:"' .. filter .. '"' },
					cwd = cwd,
					env = hybris_env(),
				}
			else
				local quoted = vim.tbl_map(vim.fn.shellescape, parts)
				task = {
					cmd = {
						"sh",
						"-c",
						table.concat(quoted, " ") .. " | grep --line-buffered " .. vim.fn.shellescape(filter),
					},
					cwd = cwd,
					env = hybris_env(),
				}
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
			filtered_task_template("Hybris: Debug server", { server, "debug" }, platform_dir, "Server startup"),
			task_template("Hybris: All", { ant, "all" }, platform_dir),
			task_template("Hybris: Build", { ant, "build" }, platform_dir),
			task_template("Hybris: Clean", { ant, "clean" }, platform_dir),
			task_template("Hybris: Clean all", { ant, "clean", "all" }, platform_dir),
			task_template("Hybris: Update system", { ant, "updatesystem" }, platform_dir),
			task_template("Hybris: Ant (custom target)", { ant }, platform_dir),
		})
	end,
}
