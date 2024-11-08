local M = {}

local uv = vim.loop

local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

function M.join_paths(...)
	local result = table.concat({ ... }, path_sep)
	return result
end

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

return M
