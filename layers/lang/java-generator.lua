--- @class JavaRuntime
--- @field name string The name of the Java runtime.
--- @field path string The file system path to the Java runtime.
--- @field default boolean? Indicates if this runtime is the default one (optional).

local L = {
	name = "Java generator code",
	--- A list of available Java runtimes on the system.
	--- @type JavaRuntime[]?
	runtimes = nil,
	runtime_env_vars = {
		"JDK_HOME",
		"JRE_HOME",
		"JAVA8_HOME",
		"JAVA11_HOME",
		"JAVA17_HOME",
		"JAVA21_HOME",
	},
}

---@param path string
---@return boolean
local function is_valid_java_home(path)
	if path == nil or path == "" then
		return false
	end
	if vim.fn.isdirectory(path) ~= 1 then
		return false
	end
	return vim.fn.executable(path .. "/bin/java") == 1
end

---@param path string
---@return string?
local function java_version_from_release(path)
	local release_file = path .. "/release"
	local file = io.open(release_file, "r")
	if file == nil then
		return nil
	end
	local content = file:read("*a")
	file:close()
	if content == nil then
		return nil
	end
	return content:match('JAVA_VERSION="([^"]+)"')
end

---@param version string?
---@return string?
local function runtime_name_from_version(version)
	if not version then
		return nil
	end
	local major = tonumber(version:match("^(%d+)"))
	if not major then
		return nil
	end
	if major <= 8 then
		return "JavaSE-1." .. tostring(major)
	end
	return "JavaSE-" .. tostring(major)
end

---@param path string
---@return string
local function runtime_name_from_path(path)
	local version = java_version_from_release(path)
	local name = runtime_name_from_version(version)
	if name then
		return name
	end
	return "JDK-" .. vim.fn.fnamemodify(path, ":t")
end

---@param path string
---@return string
local function normalize_path(path)
	return vim.fn.fnamemodify(path, ":p")
end

-- Returns `base_name` unchanged the first time it's requested; every
-- subsequent (colliding) request gets a "(source)" suffix so runtimes never
-- share a name (jdtls's configuration.runtimes keys off name). Falls back to
-- a numbered suffix in the rare case even the source-suffixed name collides
-- (e.g. two candidates from the same source resolve to the same version).
---@param base_name string
---@param source string
---@param used_names table<string, boolean>
---@return string
local function unique_name(base_name, source, used_names)
	if not used_names[base_name] then
		used_names[base_name] = true
		return base_name
	end
	local suffixed = string.format("%s (%s)", base_name, source)
	if not used_names[suffixed] then
		used_names[suffixed] = true
		return suffixed
	end
	local n = 2
	local candidate = string.format("%s (%s %d)", base_name, source, n)
	while used_names[candidate] do
		n = n + 1
		candidate = string.format("%s (%s %d)", base_name, source, n)
	end
	used_names[candidate] = true
	return candidate
end

---@param runtimes JavaRuntime[]
---@param seen table<string, boolean>
---@param used_names table<string, boolean>
---@param path string
---@param is_default boolean?
---@param source string
local function add_runtime(runtimes, seen, used_names, path, is_default, source)
	if not is_valid_java_home(path) then
		return
	end
	local normalized_path = normalize_path(path)
	if seen[normalized_path] then
		return
	end
	seen[normalized_path] = true
	local runtime = {
		name = unique_name(runtime_name_from_path(normalized_path), source, used_names),
		path = normalized_path,
	}
	if is_default then
		runtime.default = true
	end
	table.insert(runtimes, runtime)
end

---@param root string
---@param runtimes JavaRuntime[]
---@param seen table<string, boolean>
---@param used_names table<string, boolean>
---@param source string
---@param opts table?
local function add_runtime_children(root, runtimes, seen, used_names, source, opts)
	opts = opts or {}
	if vim.fn.isdirectory(root) ~= 1 then
		return
	end
	local pattern = root .. "/*"
	local candidates = vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })
	for _, candidate in ipairs(candidates) do
		if opts.filter and not opts.filter(candidate) then
			goto continue
		end
		local java_home = candidate
		if opts.transform then
			java_home = opts.transform(candidate)
		end
		add_runtime(runtimes, seen, used_names, java_home, false, source)
		::continue::
	end
end

---@param env_name string
---@param default_path string
---@return string
local function resolve_dir_from_env(env_name, default_path)
	return os.getenv(env_name) or default_path
end

local function find_closest_root(current_path)
	local java_index = string.find(current_path, "/java/")
	if java_index then
		return string.sub(current_path, 1, java_index + 5)
	end

	return nil
end

function L.get_package(current_file)
	current_file = current_file or vim.fn.expand("%")
	local root_folder = find_closest_root(current_file)
	if root_folder == nil then
		vim.notify("No java folder found", vim.log.levels.ERROR)
		return "default_package"
	end
	local current_file_folder = vim.fn.fnamemodify(current_file, ":h")
	local relative_path = string.sub(current_file_folder, #root_folder + 1)
	local package_name = relative_path
	package_name, _ = string.gsub(package_name, "-", "_")
	package_name, _ = string.gsub(package_name, "\\", ".")
	package_name, _ = string.gsub(package_name, "/", ".")
	vim.notify("Found file namespace: " .. package_name, vim.log.levels.INFO)
	return package_name
end

--- Returns a list of available Java runtimes on the system.
--- @return JavaRuntime[] A list of Java runtimes, each containing a name and path.
function L.get_runtimes()
	if L.runtimes then
		return L.runtimes
	end
	local result = {}
	local seen = {}
	local used_names = {}
	--- Obtain the runtime from environment variables
	local java_home = os.getenv("JAVA_HOME")
	if java_home then
		add_runtime(result, seen, used_names, java_home, true, "JAVA_HOME")
	end

	for _, env_name in ipairs(L.runtime_env_vars) do
		local env_path = os.getenv(env_name)
		if env_path then
			add_runtime(result, seen, used_names, env_path, false, env_name)
		end
	end

	local home = os.getenv("HOME")
	if home and home ~= "" then
		local sdkman_root = resolve_dir_from_env("SDKMAN_DIR", home .. "/.sdkman")
		local asdf_root = resolve_dir_from_env("ASDF_DATA_DIR", home .. "/.asdf")
		local jabba_root = resolve_dir_from_env("JABBA_HOME", home .. "/.jabba")
		local jenv_root = resolve_dir_from_env("JENV_ROOT", home .. "/.jenv")

		add_runtime_children(sdkman_root .. "/candidates/java", result, seen, used_names, "sdkman", {
			filter = function(candidate)
				return vim.fn.fnamemodify(candidate, ":t") ~= "current"
			end,
		})
		add_runtime_children(asdf_root .. "/installs/java", result, seen, used_names, "asdf")
		add_runtime_children(jabba_root .. "/jdk", result, seen, used_names, "jabba")
		add_runtime_children(jenv_root .. "/versions", result, seen, used_names, "jenv")
	end

	add_runtime_children("/usr/lib/jvm", result, seen, used_names, "system")
	add_runtime_children("/usr/java", result, seen, used_names, "system")
	add_runtime_children("/Library/Java/JavaVirtualMachines", result, seen, used_names, "macos", {
		transform = function(candidate)
			return candidate .. "/Contents/Home"
		end,
	})

	L.runtimes = result
	return L.runtimes
end

return L
