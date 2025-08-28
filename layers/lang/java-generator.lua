local L = { name = "Java generator code" }

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

return L
