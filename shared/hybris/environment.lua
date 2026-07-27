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

local java_common = require("LYRD.shared.java-common")

local is_windows = vim.fn.has("win32") == 1

local M = {
	REQUIRED_JAVA_VERSION = 17,
}

local warned_missing = false

---@return JavaRuntime?
function M.find_runtime()
	for _, runtime in ipairs(java_common.get_runtimes()) do
		if tonumber(runtime.name:match("JavaSE%-(%d+)")) == M.REQUIRED_JAVA_VERSION then
			return runtime
		end
	end
	return nil
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
		PATH = runtime.path .. "/bin" .. sep .. (os.getenv("PATH") or ""),
	}
end

return M
