--- @class JavaRuntime
--- @field name string The name of the Java runtime.
--- @field path string The file system path to the Java runtime.
--- @field default boolean? Indicates if this runtime is the default one (optional).

local L = {
	name = "Java generator code",
	--- A list of available Java runtimes on the system.
	--- @type JavaRuntime[]?
	runtimes = nil,
}

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
	--- Obtain the runtime from environment variables
	local java_home = os.getenv("JAVA_HOME")
	if java_home then
		table.insert(result, { name = "JAVA_HOME", path = java_home, default = true })
	end
	return result
end

return L
