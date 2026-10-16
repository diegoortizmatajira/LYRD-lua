local hotswap_runtime = require("LYRD.shared.hybris.hotswap_runtime")
local hybris_environment = require("LYRD.shared.hybris.environment")

--- Environment variable used to locate the Hybris installation.
local HYBRIS_HOME_ENV = "HYBRIS_HOME"

local is_windows = vim.fn.has("win32") == 1
local server_script = is_windows and "hybrisserver.bat" or "hybrisserver.sh"
local ant_script = is_windows and "ant.bat" or "ant"

-- Env overrides applied to every Hybris task so ant/the server always run on
-- the required Java version (shared/hybris/environment.lua) regardless of the
-- ambient JAVA_HOME (e.g. set to 21 for jdtls).
---@return table<string, string>
local function hybris_env()
	return hybris_environment.env_overrides()
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

---@param name string
---@param command string[]
---@param cwd string
---@param opts? { strategy?: string } strategy defaults to overseer's own default ("terminal").
---Pass strategy = "tmux" for long-running tasks (e.g. servers) that should survive
---closing Neovim and be reattached to later (see shared/overseer/tmux_strategy.lua).
local function task_template(name, command, cwd, opts)
	opts = opts or {}
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
			local task = { cmd = vim.deepcopy(command), cwd = cwd, env = hybris_env(), strategy = opts.strategy }
			if params.args and #params.args > 0 then
				task.args = params.args
			end
			return task
		end,
	}
end

-- Overseer calls template builders without a pcall, so erroring out would just
-- dump a traceback. Instead, a builder that must not launch its command returns
-- this stand-in: it prints the problems and exits 1, so the task shows up as
-- failed with the reason in its output (and nothing like a tmux session is
-- left behind).
---@param name string
---@param problems string[]
---@param cwd string
---@return overseer.TaskDefinition
local function aborted_task(name, problems, cwd)
	vim.schedule(function()
		vim.notify(name .. " aborted:\n" .. table.concat(problems, "\n"), vim.log.levels.ERROR)
	end)
	if is_windows then
		local lines = vim.tbl_map(function(p)
			return "echo " .. p:gsub("[%^&|<>]", "^%0")
		end, problems)
		return { cmd = { "cmd.exe", "/c", table.concat(lines, " & ") .. " & exit /b 1" }, cwd = cwd }
	end
	local cmd = { "sh", "-c", 'printf "%s\\n" "$@" >&2; exit 1', "sh" }
	vim.list_extend(cmd, problems)
	return { cmd = cmd, cwd = cwd }
end

-- Like task_template, but pipes the command's output through a filter so only
-- matching lines reach the task's output buffer (e.g. the server's verbose
-- debug-mode logging would otherwise peg Neovim's terminal redraw for hours).
---@param filter string|string[] literal string(s) passed to grep/findstr; a line matching any of them is kept
---@param opts? { strategy?: string, env?: fun(): table<string, string>, preflight?: fun(): string[] }
---see task_template; env returns extra env vars merged over hybris_env(), and
---preflight runs when the task is built and returns blocking problems -- if
---any, the command is not launched (see aborted_task).
local function filtered_task_template(name, command, cwd, filter, opts)
	opts = opts or {}
	local filters = type(filter) == "table" and filter or { filter }
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
			if opts.preflight then
				local problems = opts.preflight()
				if #problems > 0 then
					return aborted_task(name, problems, cwd)
				end
			end
			local env = hybris_env()
			if opts.env then
				env = vim.tbl_extend("force", env, opts.env())
			end
			---@type overseer.TaskDefinition
			local task
			if is_windows then
				local quoted = vim.tbl_map(function(p)
					return string.format('"%s"', p)
				end, parts)
				local findstr_args = vim.tbl_map(function(f)
					return '/C:"' .. f .. '"'
				end, filters)
				task = {
					cmd = {
						"cmd.exe",
						"/c",
						table.concat(quoted, " ") .. " | findstr " .. table.concat(findstr_args, " "),
					},
					cwd = cwd,
					env = env,
					strategy = opts.strategy,
				}
			else
				local quoted = vim.tbl_map(vim.fn.shellescape, parts)
				local grep_args = vim.tbl_map(function(f)
					return "-e " .. vim.fn.shellescape(f)
				end, filters)
				task = {
					cmd = {
						"sh",
						"-c",
						table.concat(quoted, " ") .. " | grep --line-buffered " .. table.concat(grep_args, " "),
					},
					cwd = cwd,
					env = env,
					strategy = opts.strategy,
				}
			end
			return task
		end,
	}
end

-- Only a JetBrains Runtime (JBR) with HotswapAgent installed at
-- <jbr>/lib/hotswap/hotswap-agent.jar understands these (see
-- shared/hybris/hotswap_runtime.lua).
local HOTSWAP_JAVA_OPTIONS = table.concat(hotswap_runtime.JAVA_OPTIONS, " ")

-- hybrisserver.sh passes no extra args through to the JVM, and the JVM's
-- options are baked into tomcat/conf/wrapper-debug.conf at `ant all` time, so
-- the hotswap flags go in via JAVA_TOOL_OPTIONS (honored by every JVM) instead,
-- appended to any ambient value.
---@return table<string, string>
local function hotswap_env()
	local ambient = os.getenv("JAVA_TOOL_OPTIONS")
	local value = (ambient and ambient ~= "") and (ambient .. " " .. HOTSWAP_JAVA_OPTIONS) or HOTSWAP_JAVA_OPTIONS
	return { JAVA_TOOL_OPTIONS = value }
end

-- Hybris bakes the build JVM's java.home into the generated wrapper conf at
-- `ant all` time, so that's the JVM the server actually runs on -- not
-- whatever JAVA17_HOME currently resolves to.
---@param platform_dir string
---@return string?
local function server_java_home(platform_dir)
	local conf = platform_dir .. "/tomcat/conf/wrapper-debug.conf"
	if vim.fn.filereadable(conf) == 0 then
		return nil
	end
	for _, line in ipairs(vim.fn.readfile(conf)) do
		local command = line:match("^%s*wrapper%.java%.command%s*=%s*(.-)%s*$")
		if command then
			local home = command:gsub("%.exe$", ""):gsub("[/\\]bin[/\\]java$", "")
			return home
		end
	end
	return nil
end

-- A plain JDK rejects the hotswap flags and the JVM dies on startup (with the
-- wrapper retrying it a few times), so check the setup up front and refuse to
-- launch instead.
---@param platform_dir string
---@return string[] problems empty when the server can be launched with hotswap
local function hotswap_preflight(platform_dir)
	local problems = {}
	local java_home = server_java_home(platform_dir)
	if not java_home then
		table.insert(problems, "tomcat/conf/wrapper-debug.conf not found; run `Hybris: All` first")
	else
		if not hotswap_runtime.is_jbr(java_home) then
			table.insert(
				problems,
				string.format(
					"server JVM (%s) is not a JetBrains Runtime; set $JBR_HOME to a JBRSDK 17 or run `Hybris: Install hotswap runtime`, then `Hybris: All`",
					java_home
				)
			)
		end
		local agent = java_home .. "/lib/hotswap/hotswap-agent.jar"
		if vim.fn.filereadable(agent) == 0 then
			table.insert(
				problems,
				string.format(
					"HotswapAgent not installed at %s; copy hotswap-agent.jar there or run `Hybris: Install hotswap runtime`, then `Hybris: All`",
					agent
				)
			)
		end
	end
	return problems
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
			task_template("Hybris: Start server", { server, "start" }, platform_dir, { strategy = "tmux" }),
			task_template("Hybris: Stop server", { server, "stop" }, platform_dir),
			filtered_task_template(
				"Hybris: Debug server",
				{ server, "debug" },
				platform_dir,
				"Server startup",
				{ strategy = "tmux" }
			),
			-- Debug mode (so jdtls/nvim-dap hot code replace still works when
			-- attached) plus JBR enhanced redefinition and HotswapAgent.
			filtered_task_template("Hybris: Hotswap server", { server, "debug" }, platform_dir, {
				"Server startup",
				"HOTSWAP AGENT",
				"Could not create the Java Virtual Machine",
				"Unrecognized VM option",
			}, {
				strategy = "tmux",
				env = hotswap_env,
				preflight = function()
					return hotswap_preflight(platform_dir)
				end,
			}),
			task_template("Hybris: All", { ant, "all" }, platform_dir),
			task_template("Hybris: Build", { ant, "build" }, platform_dir),
			task_template("Hybris: Clean", { ant, "clean" }, platform_dir),
			task_template("Hybris: Clean all", { ant, "clean", "all" }, platform_dir),
			task_template("Hybris: Customize", { ant, "customize" }, platform_dir),
			task_template("Hybris: Update system", { ant, "updatesystem" }, platform_dir),
			task_template("Hybris: Ant (custom target)", { ant }, platform_dir),
		})
	end,
}
