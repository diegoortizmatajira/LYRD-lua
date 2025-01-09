local L = { name = "Dotnet generator code" }

local function find_closest_csproj(current_path, max_levels)
	local levels = 0

	while levels < max_levels do
		local csproj_files = vim.fn.globpath(current_path, "*.csproj", false, true)
		if #csproj_files > 0 then
			return csproj_files[1]
		end

		local parent_path = vim.fn.fnamemodify(current_path, ":h")
		if parent_path == current_path then
			break
		end

		current_path = parent_path
		levels = levels + 1
	end

	return nil
end

function L.get_namespace(current_file)
	current_file = current_file or vim.fn.expand("%")
	local csproj = find_closest_csproj(current_file, 5)
	if csproj == nil then
		vim.notify("No C# Project file found", vim.log.levels.ERROR)
		return "default_namespace"
	end
	local csproj_folder = vim.fn.fnamemodify(csproj, ":h")
	local current_file_folder = vim.fn.fnamemodify(current_file, ":h")
	local relative_path = string.sub(current_file_folder, #csproj_folder + 1)
	local namespace = vim.fn.fnamemodify(csproj, ":t:r") .. relative_path
	namespace, _ = string.gsub(namespace, "-", "_")
	namespace, _ = string.gsub(namespace, "\\", ".")
	namespace, _ = string.gsub(namespace, "/", ".")
	vim.notify("Found file namespace: " .. namespace, vim.log.levels.INFO)
	return namespace
end

return L
