-- Installs a JetBrains Runtime SDK 17 (JBRSDK -- a full JDK, since Hybris'
-- ant build needs javac) plus HotswapAgent, so the "Hybris: Hotswap server"
-- overseer task (shared/overseer/hybris_tasks.lua) can run with enhanced class
-- redefinition. The installed JDK home is persisted under the LYRD data dir and
-- preferred by shared/hybris/environment.lua for every Hybris ant/server task.
--
--   M.install(location)  -- async download/verify/extract; notifies progress
--   M.installed_home()   -- persisted JDK home, or nil if absent/invalid

local utils = require("LYRD.shared.utils")

local M = {
	DEFAULT_LOCATION = "~/.jdks",
	-- Enhanced class redefinition (new methods/fields/classes) plus HotswapAgent's
	-- framework reloading (Spring beans etc.), using the agent jar installed at
	-- <jbr>/lib/hotswap/hotswap-agent.jar.
	JAVA_OPTIONS = { "-XX:+AllowEnhancedClassRedefinition", "-XX:HotswapAgent=fatjar" },
}

local JBR_RELEASES_URL = "https://api.github.com/repos/JetBrains/JetBrainsRuntime/releases"
local HOTSWAP_AGENT_LATEST_URL = "https://api.github.com/repos/HotswapProjects/HotswapAgent/releases/latest"
-- JBR's GitHub releases carry no assets; the download links live in the
-- release notes. Older releases are paged through until a JBR 17 one turns up.
local JBR_MAX_PAGES = 5

local is_windows = vim.fn.has("win32") == 1

---@return string
local function state_path()
	return utils.get_lyrd_data_path(utils.join_paths("hybris", "hotswap-runtime.json"))
end

---@param home string
---@return boolean
local function is_java_home(home)
	local java = home .. "/bin/java" .. (is_windows and ".exe" or "")
	return vim.fn.executable(java) == 1
end

---@param home string
---@return boolean
function M.is_jbr(home)
	local release = home .. "/release"
	if vim.fn.filereadable(release) ~= 1 then
		return false
	end
	for _, line in ipairs(vim.fn.readfile(release)) do
		if line:match("^IMPLEMENTOR=.*JetBrains") then
			return true
		end
	end
	return false
end

-- Major Java version from <home>/release (e.g. 17), or nil if unknown.
---@param home string
---@return integer?
function M.java_major(home)
	local release = home .. "/release"
	if vim.fn.filereadable(release) ~= 1 then
		return nil
	end
	for _, line in ipairs(vim.fn.readfile(release)) do
		local version = line:match('^JAVA_VERSION="([^"]+)"')
		if version then
			-- "1.8.0_x" style versions report their major after the "1."
			local major = tonumber(version:match("^1%.(%d+)") or version:match("^(%d+)"))
			return major
		end
	end
	return nil
end

---@param home string
---@return boolean
function M.has_agent(home)
	return vim.fn.filereadable(home .. "/lib/hotswap/hotswap-agent.jar") == 1
end

---@return string?
function M.installed_home()
	local path = state_path()
	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end
	local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
	if not ok or type(data) ~= "table" or type(data.java_home) ~= "string" then
		return nil
	end
	return is_java_home(data.java_home) and data.java_home or nil
end

---@param state table
local function save_state(state)
	local path = state_path()
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	vim.fn.writefile({ vim.json.encode(state) }, path)
end

---@param msg string
---@param level? integer
local function notify(msg, level)
	vim.notify("Hybris hotswap runtime: " .. msg, level or vim.log.levels.INFO)
end

-- ─── Coroutine plumbing ───────────────────────────────────────────────────────
-- The install is a linear chain of slow external commands; running it as a
-- coroutine over vim.system keeps it readable without blocking the editor.

---@param co thread
local function resume(co, ...)
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		notify(tostring(err), vim.log.levels.ERROR)
	end
end

---@param msg string
local function fail(msg)
	error(msg, 0)
end

---@param cmd string[]
---@return vim.SystemCompleted
local function system(cmd)
	local co = coroutine.running()
	vim.system(cmd, { text = true }, function(result)
		vim.schedule(function()
			resume(co, result)
		end)
	end)
	return coroutine.yield()
end

-- Runs cmd and returns its stdout, failing the install on a non-zero exit.
---@param cmd string[]
---@param what string description used in the failure message
---@return string
local function check(cmd, what)
	local result = system(cmd)
	if result.code ~= 0 then
		fail(string.format("%s failed: %s", what, vim.trim(result.stderr or "")))
	end
	return result.stdout or ""
end

---@param url string
---@return any
local function github_json(url)
	local body = check({ "curl", "-fsSL", "-H", "Accept: application/vnd.github+json", url }, "GitHub API request")
	local ok, data = pcall(vim.json.decode, body)
	if not ok then
		fail("could not parse GitHub API response from " .. url)
	end
	return data
end

---@param url string
---@param dest string
local function download(url, dest)
	check({ "curl", "-fsSL", "-o", dest, url }, "download of " .. url)
end

-- ─── Install steps ────────────────────────────────────────────────────────────

-- Maps the host to JBR's "<os>-<arch>" asset naming.
---@return string os_name, string arch
local function platform()
	local uname = vim.uv.os_uname()
	local os_name = ({ Linux = "linux", Darwin = "osx", Windows_NT = "windows" })[uname.sysname]
	local arch = ({ x86_64 = "x64", AMD64 = "x64", aarch64 = "aarch64", arm64 = "aarch64" })[uname.machine]
	if not os_name or not arch then
		fail(string.format("unsupported platform %s/%s", uname.sysname, uname.machine))
	end
	return os_name, arch
end

-- Finds the newest JBR 17 release with a vanilla JBRSDK .tar.gz for this
-- platform (skipping the musl, fastdebug and _diz debug-symbol variants).
---@return string tag, string url
local function find_jbrsdk(os_name, arch)
	local pattern = "https://cache%-redirector%.jetbrains%.com/intellij%-jbr/jbrsdk%-17[%d%.]*%-"
		.. os_name
		.. "%-"
		.. arch
		.. "%-b[%d%.]+%.tar%.gz"
	for page = 1, JBR_MAX_PAGES do
		local releases = github_json(string.format("%s?per_page=100&page=%d", JBR_RELEASES_URL, page))
		if type(releases) ~= "table" or #releases == 0 then
			break
		end
		-- GitHub lists releases newest first, so the first match is the latest.
		for _, release in ipairs(releases) do
			if type(release.tag_name) == "string" and release.tag_name:match("^jbr%-release%-17%.") then
				local url = type(release.body) == "string" and release.body:match(pattern)
				if url then
					return release.tag_name, url
				end
			end
		end
	end
	fail(string.format("no JBRSDK 17 build found for %s-%s", os_name, arch))
	return "", ""
end

---@param file string
---@return string[]?
local function sha512_command(file)
	if vim.fn.executable("sha512sum") == 1 then
		return { "sha512sum", file }
	elseif vim.fn.executable("shasum") == 1 then
		return { "shasum", "-a", "512", file }
	elseif vim.fn.executable("certutil") == 1 then
		return { "certutil", "-hashfile", file, "SHA512" }
	end
	return nil
end

---@param text string
---@return string?
local function first_sha512(text)
	for hex in text:gmatch("%x+") do
		if #hex == 128 then
			return hex:lower()
		end
	end
	return nil
end

---@param url string
---@param file string
local function verify_checksum(url, file)
	local cmd = sha512_command(file)
	if not cmd then
		notify("no sha512sum/shasum/certutil found; skipping checksum verification", vim.log.levels.WARN)
		return
	end
	local expected = first_sha512(check({ "curl", "-fsSL", url .. ".checksum" }, "checksum download"))
	local actual = first_sha512(check(cmd, "checksum computation"))
	if not expected or expected ~= actual then
		fail("checksum mismatch for " .. url)
	end
end

---@param location string
---@param os_name string
---@param arch string
---@return string home, string tag
local function install_jbrsdk(location, os_name, arch)
	notify("looking up the latest JBR 17 release...")
	local tag, url = find_jbrsdk(os_name, arch)
	-- The archive unpacks into a single directory named after it; macOS builds
	-- are .app-style bundles with the JDK under Contents/Home.
	local root = location .. "/" .. url:match("([^/]+)%.tar%.gz$")
	local home = os_name == "osx" and (root .. "/Contents/Home") or root
	if is_java_home(home) then
		notify(string.format("%s already present at %s; reusing it", tag, root))
		return home, tag
	end

	local archive = vim.fn.tempname() .. ".tar.gz"
	notify(string.format("downloading %s...", tag))
	download(url, archive)
	verify_checksum(url, archive)
	vim.fn.mkdir(location, "p")
	check({ "tar", "-xzf", archive, "-C", location }, "extraction")
	vim.fn.delete(archive)
	if not is_java_home(home) then
		fail("extracted archive has no bin/java at " .. home)
	end
	return home, tag
end

---@param home string
---@return string tag
local function install_hotswap_agent(home)
	notify("looking up the latest HotswapAgent release...")
	local release = github_json(HOTSWAP_AGENT_LATEST_URL)
	for _, asset in ipairs(type(release.assets) == "table" and release.assets or {}) do
		if type(asset.name) == "string" and asset.name:match("^hotswap%-agent%-[%d%.]+%.jar$") then
			local dir = home .. "/lib/hotswap"
			vim.fn.mkdir(dir, "p")
			notify(string.format("downloading %s...", asset.name))
			-- JBR only looks for this exact, unversioned file name.
			download(asset.browser_download_url, dir .. "/hotswap-agent.jar")
			return release.tag_name
		end
	end
	fail("no hotswap-agent jar found in the latest HotswapAgent release")
	return ""
end

---@param location string directory the JBRSDK is extracted into (e.g. ~/.jdks)
function M.install(location)
	for _, exe in ipairs({ "curl", "tar" }) do
		if vim.fn.executable(exe) == 0 then
			notify(string.format("`%s` is required but was not found in PATH", exe), vim.log.levels.ERROR)
			return
		end
	end
	location = vim.fn.fnamemodify(vim.fn.expand(location), ":p"):gsub("[/\\]$", "")

	resume(coroutine.create(function()
		local os_name, arch = platform()
		local home, jbr_tag = install_jbrsdk(location, os_name, arch)
		local agent_tag = install_hotswap_agent(home)

		local java = home .. "/bin/java"
		local verify_cmd = vim.list_extend({ java }, M.JAVA_OPTIONS)
		table.insert(verify_cmd, "-version")
		check(verify_cmd, "JVM check with hotswap flags")

		save_state({ java_home = home, jbr = jbr_tag, hotswap_agent = agent_tag })
		notify(
			string.format(
				"installed %s + HotswapAgent %s at %s.\n"
					.. "Hybris tasks now use this JDK; run `Hybris: All` so the server picks it up.",
				jbr_tag,
				agent_tag,
				home
			)
		)
	end))
end

return M
