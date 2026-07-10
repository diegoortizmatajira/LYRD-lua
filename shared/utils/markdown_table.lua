-- Moves the markdown pipe-table column under the cursor left or right.
-- Table structure is derived from plain text (leading/trailing pipe, cell
-- splitting that respects escaped "\|") rather than treesitter, since the
-- move only has to reorder raw cell text -- realignment is left to the
-- markdown formatter.

local M = {}

--- Splits a pipe-table row's inner content into cells, respecting escaped pipes ("\|").
---@param content string Row content with any leading/trailing "|" already stripped.
---@return string[] cells
local function split_cells(content)
	local cells = {}
	local cell = {}
	local i = 1
	local n = #content
	while i <= n do
		local c = content:sub(i, i)
		if c == "\\" and i < n then
			cell[#cell + 1] = content:sub(i, i + 1)
			i = i + 2
		elseif c == "|" then
			cells[#cells + 1] = table.concat(cell)
			cell = {}
			i = i + 1
		else
			cell[#cell + 1] = c
			i = i + 1
		end
	end
	cells[#cells + 1] = table.concat(cell)
	return cells
end

---@class LYRD.markdown_table.Row
---@field indent string Leading whitespace before the row.
---@field has_leading boolean Whether the row starts with "|".
---@field has_trailing boolean Whether the row ends with "|".
---@field cells string[] Raw cell contents (including their padding), in column order.

--- Parses a single line of a pipe table.
---@param line string
---@return LYRD.markdown_table.Row
local function parse_row(line)
	local indent, trimmed = line:match("^(%s*)(.-)%s*$")
	local has_leading = trimmed:sub(1, 1) == "|"
	local has_trailing = #trimmed > 1 and trimmed:sub(-1) == "|"
	local inner = trimmed
	if has_leading then
		inner = inner:sub(2)
	end
	if has_trailing then
		inner = inner:sub(1, -2)
	end
	return { indent = indent, has_leading = has_leading, has_trailing = has_trailing, cells = split_cells(inner) }
end

--- Rebuilds a line from a parsed row.
---@param row LYRD.markdown_table.Row
---@return string
local function rebuild_row(row)
	local line = row.indent
	if row.has_leading then
		line = line .. "|"
	end
	line = line .. table.concat(row.cells, "|")
	if row.has_trailing then
		line = line .. "|"
	end
	return line
end

--- Checks whether a row is a delimiter row (e.g. "| --- | :---: |").
---@param row LYRD.markdown_table.Row
---@return boolean
local function is_delimiter_row(row)
	for _, cell in ipairs(row.cells) do
		if not cell:match("^%s*:?%-+:?%s*$") then
			return false
		end
	end
	return #row.cells > 0
end

---@param line string?
---@return boolean
local function has_pipe(line)
	return line ~= nil and line:find("|", 1, true) ~= nil
end

--- Finds the 0-based cell index containing `col`, given the byte length of the
--- row's indent and leading pipe.
---@param row LYRD.markdown_table.Row
---@param leading_len integer
---@param col integer 0-based byte column of the cursor.
---@return integer index 1-based index into row.cells.
local function cell_index_at(row, leading_len, col)
	local offset = math.max(col - leading_len, 0)
	for i, cell in ipairs(row.cells) do
		if offset <= #cell then
			return i
		end
		offset = offset - #cell - 1
	end
	return #row.cells
end

--- Returns the byte column where cell `idx` starts, relative to the start of the line.
---@param row LYRD.markdown_table.Row
---@param leading_len integer
---@param idx integer 1-based cell index.
---@return integer
local function cell_start_col(row, leading_len, idx)
	local offset = leading_len
	for i = 1, idx - 1 do
		offset = offset + #row.cells[i] + 1
	end
	return offset
end

--- Moves the table column under the cursor one position left (-1) or right (1).
--- Only operates on the contiguous block of pipe-containing lines around the
--- cursor, and only if that block contains a delimiter row -- otherwise the
--- cursor isn't considered to be inside a markdown table.
---@param direction -1|1
---@param bufnr? integer
---@param win? integer
function M.move_column(direction, bufnr, win)
	bufnr = bufnr or 0
	win = win or 0

	local cursor = vim.api.nvim_win_get_cursor(win)
	local lnum, col = cursor[1], cursor[2]
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	if not has_pipe(lines[lnum]) then
		vim.notify("Cursor is not inside a markdown table", vim.log.levels.WARN)
		return
	end

	local first, last = lnum, lnum
	while first > 1 and has_pipe(lines[first - 1]) do
		first = first - 1
	end
	while last < #lines and has_pipe(lines[last + 1]) do
		last = last + 1
	end

	local rows = {}
	local has_delimiter = false
	for i = first, last do
		local row = parse_row(lines[i])
		if is_delimiter_row(row) then
			has_delimiter = true
		end
		rows[#rows + 1] = row
	end

	if not has_delimiter then
		vim.notify("Cursor is not inside a markdown table", vim.log.levels.WARN)
		return
	end

	local current_row = rows[lnum - first + 1]
	local leading_len = #current_row.indent + (current_row.has_leading and 1 or 0)
	local col_idx = cell_index_at(current_row, leading_len, col)
	local target_idx = col_idx + direction

	if target_idx < 1 or target_idx > #current_row.cells then
		vim.notify("Cannot move the column further " .. (direction < 0 and "left" or "right"), vim.log.levels.WARN)
		return
	end

	local new_lines = {}
	for i, row in ipairs(rows) do
		if col_idx > #row.cells or target_idx > #row.cells then
			vim.notify("Table rows have mismatched column counts", vim.log.levels.ERROR)
			return
		end
		row.cells[col_idx], row.cells[target_idx] = row.cells[target_idx], row.cells[col_idx]
		new_lines[i] = rebuild_row(row)
	end

	vim.api.nvim_buf_set_lines(bufnr, first - 1, last, false, new_lines)
	vim.api.nvim_win_set_cursor(win, { lnum, cell_start_col(current_row, leading_len, target_idx) })
end

return M
