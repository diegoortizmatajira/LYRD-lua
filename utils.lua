local uv = vim.loop
local M = {
	path_sep = uv.os_uname().version:match("Windows") and "\\" or "/",
}

--- Gets lyrd path
function M.get_lyrd_path()
	return vim.fn.stdpath("config") .. "/lua/LYRD"
end

--- Joins paths
--- @param ... any
function M.join_paths(...)
	local result = table.concat({ ... }, M.path_sep)
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

--- Retrieves the visually selected text in the current buffer.
---
--- This function identifies the range of visually selected lines in the current
--- buffer and extracts the selected text. It adjusts the text boundaries to
--- ensure only the selected portion is included, considering both the start
--- and end columns of the selection.
---
--- The function is useful for scenarios where a specific portion of the text
--- needs to be processed, such as running a database query on a selected range
--- of lines.
---
--- @return string The text within the visually selected range, or an empty string if no text is selected.
function M.get_visual_selection(bufnr)
	local mode = vim.api.nvim_get_mode().mode
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		return "" -- Not in visual mode
	end
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local start = vim.fn.getpos("v")
	local end_ = vim.fn.getpos(".")
	local start_row = start[2] - 1
	local start_col = start[3] - 1
	local end_row = end_[2] - 1
	local end_col = end_[3] - 1

	-- A user can start visual selection at the end and move backwards
	-- Normalize the range to start < end
	if start_row == end_row and end_col < start_col then
		end_col, start_col = start_col, end_col
	elseif end_row < start_row then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end
	if mode == "V" then
		start_col = 0
		local lines = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, true)
		end_col = #lines[1]
	end
	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col + 1, {})
	return table.concat(lines, "\n")
end
return M
