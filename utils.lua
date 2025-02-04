local M = {}

local uv = vim.loop

local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

--- Gets lyrd path
function M.get_lyrd_path()
	return vim.fn.stdpath("config") .. "/lua/LYRD"
end

--- Joins paths
--- @param ... any
function M.join_paths(...)
	local result = table.concat({ ... }, path_sep)
	return result
end

--- Adds a path to the system path
--- @param path_to_add string
--- @param append boolean
function M.include_in_system_path(path_to_add, append)
	if vim.env.PATH:match(path_to_add) then
		return
	end
	local string_separator = vim.loop.os_uname().version:match("Windows") and ";" or ":"
	if append then
		vim.env.PATH = vim.env.PATH .. string_separator .. path_to_add
	else
		vim.env.PATH = path_to_add .. string_separator .. vim.env.PATH
	end
end

--- Checks if a list contains an item
--- @param list table
--- @param item any
function M.contains(list, item)
	for _, str in ipairs(list) do
		if str == item then
			return true
		end
	end
	return false
end

return M
