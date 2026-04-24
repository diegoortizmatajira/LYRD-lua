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

---@param runtimes JavaRuntime[]
---@param seen table<string, boolean>
---@param path string
---@param is_default boolean?
local function add_runtime(runtimes, seen, path, is_default)
	if not is_valid_java_home(path) then
		return
	end
	local normalized_path = normalize_path(path)
	if seen[normalized_path] then
		return
	end
	seen[normalized_path] = true
	local runtime = {
		name = runtime_name_from_path(normalized_path),
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
---@param opts table?
local function add_runtime_children(root, runtimes, seen, opts)
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
		add_runtime(runtimes, seen, java_home, false)
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
	--- Obtain the runtime from environment variables
	local java_home = os.getenv("JAVA_HOME")
	if java_home then
		add_runtime(result, seen, java_home, true)
	end

	for _, env_name in ipairs(L.runtime_env_vars) do
		local env_path = os.getenv(env_name)
		if env_path then
			add_runtime(result, seen, env_path, false)
		end
	end

	local home = os.getenv("HOME")
	if home and home ~= "" then
		local sdkman_root = resolve_dir_from_env("SDKMAN_DIR", home .. "/.sdkman")
		local asdf_root = resolve_dir_from_env("ASDF_DATA_DIR", home .. "/.asdf")
		local jabba_root = resolve_dir_from_env("JABBA_HOME", home .. "/.jabba")
		local jenv_root = resolve_dir_from_env("JENV_ROOT", home .. "/.jenv")

		add_runtime_children(sdkman_root .. "/candidates/java", result, seen, {
			filter = function(candidate)
				return vim.fn.fnamemodify(candidate, ":t") ~= "current"
			end,
		})
		add_runtime_children(asdf_root .. "/installs/java", result, seen)
		add_runtime_children(jabba_root .. "/jdk", result, seen)
		add_runtime_children(jenv_root .. "/versions", result, seen)
	end

	add_runtime_children("/usr/lib/jvm", result, seen)
	add_runtime_children("/usr/java", result, seen)
	add_runtime_children("/Library/Java/JavaVirtualMachines", result, seen, {
		transform = function(candidate)
			return candidate .. "/Contents/Home"
		end,
	})

	L.runtimes = result
	return L.runtimes
end

return L
