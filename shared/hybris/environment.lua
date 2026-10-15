-- Centralizes the "Hybris' own ant build/server tooling requires Java 17"
-- contract shared by the java-hybris layer's healthcheck
-- (layers/lang/java-hybris.lua) and the Hybris overseer tasks' env overrides
-- (shared/overseer/hybris_tasks.lua) -- independent of whatever JAVA_HOME
-- happens to be ambient for other tools in this session (e.g. jdtls is
-- pinned to Java 21 to launch its own OSGi server process -- see
-- runtime/lsp/jdtls.lua's resolve_launcher_java). Search java-common.lua's
-- discovered runtimes (which already picks up $JAVA17_HOME, sdkman, asdf,
-- jenv, system JVM dirs, etc.) for a matching JDK instead of trusting the
-- ambient environment.

local hotswap_runtime = require("LYRD.shared.hybris.hotswap_runtime")
local java_common = require("LYRD.shared.java-common")

local is_windows = vim.fn.has("win32") == 1

local M = {
	REQUIRED_JAVA_VERSION = 17,
}

--- Optional: points at the JBRSDK 17 Hybris tasks must use (highest priority).
local JBR_HOME_ENV = "JBR_HOME"

local warned_missing = false
local warned_jbr_home = false

-- Only a JBR *SDK* counts: ant needs javac, which the plain JBR runtimes
-- bundled with JetBrains IDEs lack.
---@param home string
---@return integer 2 = JBRSDK with HotswapAgent, 1 = JBRSDK, 0 = anything else
local function runtime_score(home)
	if not hotswap_runtime.is_jbr(home) or vim.fn.executable(home .. "/bin/javac") ~= 1 then
		return 0
	end
	return hotswap_runtime.has_agent(home) and 2 or 1
end

-- jenv's shims (notably the `ant` one from `jenv enable-plugin ant`) re-export
-- JAVA_HOME as jenv's own selected version, silently undoing the override
-- below -- and ant's JVM is what gets baked into the server's wrapper conf.
-- The shims only wrap binaries that also exist elsewhere on PATH, so dropping
-- them for Hybris tasks is safe.
---@param path string
---@param sep string
---@return string
local function without_jenv_shims(path, sep)
	local jenv_root = os.getenv("JENV_ROOT")
	if not jenv_root or jenv_root == "" then
		jenv_root = (os.getenv("HOME") or "") .. "/.jenv"
	end
	local shims = vim.fs.normalize(jenv_root .. "/shims")
	local kept = vim.tbl_filter(function(entry)
		return vim.fs.normalize(entry) ~= shims
	end, vim.split(path, sep, { plain = true, trimempty = true }))
	return table.concat(kept, sep)
end

-- Why $JBR_HOME can't be used as the Hybris JDK, or nil when it can.
---@param home string
---@return string?
local function jbr_home_problem(home)
	if vim.fn.executable(home .. "/bin/java") ~= 1 then
		return "has no bin/java"
	end
	if not hotswap_runtime.is_jbr(home) then
		return "is not a JetBrains Runtime"
	end
	local major = hotswap_runtime.java_major(home)
	if major ~= M.REQUIRED_JAVA_VERSION then
		return string.format("is Java %s, not %d", tostring(major or "?"), M.REQUIRED_JAVA_VERSION)
	end
	if vim.fn.executable(home .. "/bin/javac") ~= 1 then
		return "has no bin/javac (a JBR runtime, not a JBRSDK)"
	end
	return nil
end

-- Explicit, per-machine override for when several JBR 17s are around (jenv,
-- the install command, IDE leftovers) and ranking would pick the wrong one.
-- An unusable value warns once and falls through to the other sources.
---@return string?
local function jbr_home_from_env()
	local raw = os.getenv(JBR_HOME_ENV)
	if not raw or raw == "" then
		return nil
	end
	local home = vim.fs.normalize(raw)
	local problem = jbr_home_problem(home)
	if not problem then
		return home
	end
	if not warned_jbr_home then
		warned_jbr_home = true
		vim.schedule(function()
			vim.notify(
				string.format("Hybris: ignoring $%s (%s): %s.", JBR_HOME_ENV, home, problem),
				vim.log.levels.WARN
			)
		end)
	end
	return nil
end

---@return JavaRuntime?
function M.find_runtime()
	local jbr_home = jbr_home_from_env()
	if jbr_home then
		return { name = "JavaSE-" .. M.REQUIRED_JAVA_VERSION, path = jbr_home }
	end
	-- A JBRSDK installed via LYRDJavaHybrisInstallHotswapRuntime is an explicit
	-- opt-in, so it wins over whatever 17 runtime discovery would pick; that
	-- keeps ant (and therefore the java.home baked into the server's wrapper
	-- conf) on the JVM the Hotswap server task needs.
	local hotswap_home = hotswap_runtime.installed_home()
	if hotswap_home then
		return { name = "JavaSE-" .. M.REQUIRED_JAVA_VERSION, path = hotswap_home }
	end
	-- Otherwise rank the discovered 17 runtimes rather than taking the first:
	-- jenv/sdkman/etc. often hold both a plain OpenJDK 17 and a JBR 17 (in
	-- arbitrary order, and JAVA_HOME may point at either), and JBR is a full
	-- OpenJDK 17 that additionally supports the Hotswap server task. Ties keep
	-- discovery order.
	local best, best_score = nil, -1
	for _, runtime in ipairs(java_common.get_runtimes()) do
		if tonumber(runtime.name:match("JavaSE%-(%d+)")) == M.REQUIRED_JAVA_VERSION then
			local score = runtime_score(runtime.path)
			if score > best_score then
				best, best_score = runtime, score
			end
		end
	end
	return best
end

---@return boolean
function M.available()
	return M.find_runtime() ~= nil
end

-- Warns (once per session) that no matching runtime was found.
local function warn_missing()
	if warned_missing then
		return
	end
	warned_missing = true
	vim.schedule(function()
		vim.notify(
			string.format(
				"Hybris: no Java %d runtime found (checked $JAVA%d_HOME and sdkman/asdf/jenv/system JVM dirs). "
					.. "Falling back to the ambient JAVA_HOME/PATH, which may be the wrong version for "
					.. "Hybris' ant build/server.",
				M.REQUIRED_JAVA_VERSION,
				M.REQUIRED_JAVA_VERSION
			),
			vim.log.levels.WARN
		)
	end)
end

-- Env overrides for overseer tasks so ant/the server always run on the
-- required Java version regardless of the ambient JAVA_HOME (e.g. set to 21
-- for jdtls). Returns {} (no overrides, ambient JAVA_HOME/PATH untouched)
-- when no matching runtime is found, after warning once per session.
---@return table<string, string>
function M.env_overrides()
	local runtime = M.find_runtime()
	if not runtime then
		warn_missing()
		return {}
	end
	local sep = is_windows and ";" or ":"
	return {
		JAVA_HOME = runtime.path,
		PATH = runtime.path .. "/bin" .. sep .. without_jenv_shims(os.getenv("PATH") or "", sep),
	}
end

return M
