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

--- Checks if a list contains a specific item.
---
--- This function iterates over the provided list and checks if the given
--- item exists within it. If the item is found, it returns `true`; otherwise,
--- it returns `false`.
---
--- @param list table The list to search through.
--- @param item any The item to look for in the list.
--- @return boolean `true` if the item is found, `false` otherwise.
function M.contains(list, item)
	for _, str in ipairs(list) do
		if str == item then
			return true
		end
	end
	return false
end

--- Finds the index of a value in an array.
---
--- This function iterates over the provided array and checks if the specified value
--- is present. If found, it returns the index of the value. If the value is not found,
--- the function returns `nil`.
---
--- @param array table The array to search through.
--- @param value any The value to find in the array.
--- @return number|nil The index of the value if found, or `nil` otherwise.
function M.index_of(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil -- si no se encuentra el valor
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

--- Safely requires a module and executes a function with it.
--- @param mod_name string The name of the module to require.
--- @param func fun(module) The function to execute with the required module.
function M.with_safe_require(mod_name, func)
	local ok, mod = pcall(require, mod_name)
	if not ok then
		vim.notify("Module " .. mod_name .. " not loaded properly", vim.log.levels.WARN)
		return
	end
	func(mod)
end


--- Opens a file if it exists, or creates it with the given content if it doesn't.
--- It also ensures that the directory structure for the file exists.
--- @param file_path string The path of the file to open or create.
--- @param content? string The content to write to the file if it needs to be created.
function M.open_or_create_file(file_path, content)
    local dir = vim.fn.fnamemodify(file_path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    if vim.fn.filereadable(file_path) == 0 then
        local file = io.open(file_path, "w")
        if file then
            file:write(content or "")
            file:close()
        else
            vim.notify("Could not create file: " .. file_path, vim.log.levels.ERROR)
            return
        end
    end
    vim.cmd("edit " .. file_path)
end

return M
