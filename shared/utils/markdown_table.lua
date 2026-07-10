-- Edits the markdown pipe-table under the cursor: moving, inserting, or adding
-- columns/rows. Table structure is derived from plain text (leading/trailing
-- pipe, cell splitting that respects escaped "\|") rather than treesitter,
-- since these edits only reorder/duplicate raw cell text -- realignment is
-- left to the markdown formatter.

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

---@class LYRD.markdown_table.Block
---@field rows LYRD.markdown_table.Row[] Parsed rows of the table, in line order.
---@field first integer 1-based buffer line of the first row.
---@field last integer 1-based buffer line of the last row.
---@field delimiter_idx integer 1-based index into `rows` of the delimiter row.
---@field cursor_row_idx integer 1-based index into `rows` where the cursor currently is.
---@field lnum integer 1-based cursor line.
---@field col integer 0-based cursor byte column.

--- Locates the contiguous block of pipe-containing lines around the cursor
--- and confirms it is a real table by requiring a delimiter row somewhere in
--- it. Returns nil and shows a warning if the cursor isn't inside a table.
---@param bufnr integer
---@param win integer
---@return LYRD.markdown_table.Block?
local function locate_block(bufnr, win)
	local cursor = vim.api.nvim_win_get_cursor(win)
	local lnum, col = cursor[1], cursor[2]
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	if not has_pipe(lines[lnum]) then
		vim.notify("Cursor is not inside a markdown table", vim.log.levels.WARN)
		return nil
	end

	local first, last = lnum, lnum
	while first > 1 and has_pipe(lines[first - 1]) do
		first = first - 1
	end
	while last < #lines and has_pipe(lines[last + 1]) do
		last = last + 1
	end

	local rows = {}
	local delimiter_idx = nil
	for i = first, last do
		local row = parse_row(lines[i])
		if not delimiter_idx and is_delimiter_row(row) then
			delimiter_idx = #rows + 1
		end
		rows[#rows + 1] = row
	end

	if not delimiter_idx then
		vim.notify("Cursor is not inside a markdown table", vim.log.levels.WARN)
		return nil
	end

	return {
		rows = rows,
		first = first,
		last = last,
		delimiter_idx = delimiter_idx,
		cursor_row_idx = lnum - first + 1,
		lnum = lnum,
		col = col,
	}
end

--- Moves the table column under the cursor one position left (-1) or right (1).
---@param direction -1|1
---@param bufnr? integer
---@param win? integer
function M.move_column(direction, bufnr, win)
	bufnr = bufnr or 0
	win = win or 0

	local block = locate_block(bufnr, win)
	if not block then
		return
	end
	local rows = block.rows

	local current_row = rows[block.cursor_row_idx]
	local leading_len = #current_row.indent + (current_row.has_leading and 1 or 0)
	local col_idx = cell_index_at(current_row, leading_len, block.col)
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

	vim.api.nvim_buf_set_lines(bufnr, block.first - 1, block.last, false, new_lines)
	vim.api.nvim_win_set_cursor(win, { block.lnum, cell_start_col(current_row, leading_len, target_idx) })
end

--- Inserts a new empty column next to the one under the cursor, to the left
--- (-1) or right (1). The new column gets an empty cell in every row, and a
--- dash cell in the delimiter row so the table stays valid.
---@param direction -1|1
---@param bufnr? integer
---@param win? integer
function M.insert_column(direction, bufnr, win)
	bufnr = bufnr or 0
	win = win or 0

	local block = locate_block(bufnr, win)
	if not block then
		return
	end
	local rows = block.rows

	local current_row = rows[block.cursor_row_idx]
	local leading_len = #current_row.indent + (current_row.has_leading and 1 or 0)
	local col_idx = cell_index_at(current_row, leading_len, block.col)
	local new_idx = direction < 0 and col_idx or col_idx + 1

	local new_lines = {}
	for i, row in ipairs(rows) do
		local insert_at = math.min(math.max(new_idx, 1), #row.cells + 1)
		local content = is_delimiter_row(row) and " --- " or "  "
		table.insert(row.cells, insert_at, content)
		new_lines[i] = rebuild_row(row)
	end

	vim.api.nvim_buf_set_lines(bufnr, block.first - 1, block.last, false, new_lines)
	vim.api.nvim_win_set_cursor(win, { block.lnum, cell_start_col(current_row, leading_len, new_idx) })
end

--- Inserts a new empty body row above (-1) or below (1) the cursor. If the
--- cursor is on the header or delimiter row, the new row is placed as the
--- first body row instead, since inserting directly above/below there would
--- otherwise break the header/delimiter structure.
---@param direction -1|1
---@param bufnr? integer
---@param win? integer
function M.insert_row(direction, bufnr, win)
	bufnr = bufnr or 0
	win = win or 0

	local block = locate_block(bufnr, win)
	if not block then
		return
	end
	local rows = block.rows

	local delimiter_line = block.first + block.delimiter_idx - 1
	local insert_before_line -- 1-based line the new row is inserted before
	if block.lnum <= delimiter_line then
		insert_before_line = delimiter_line + 1
	elseif direction < 0 then
		insert_before_line = block.lnum
	else
		insert_before_line = block.lnum + 1
	end

	local template_row = rows[block.cursor_row_idx]
	local column_count = #rows[block.delimiter_idx].cells
	local new_cells = {}
	for i = 1, column_count do
		new_cells[i] = "  "
	end
	local new_row = {
		indent = template_row.indent,
		has_leading = template_row.has_leading,
		has_trailing = template_row.has_trailing,
		cells = new_cells,
	}

	vim.api.nvim_buf_set_lines(bufnr, insert_before_line - 1, insert_before_line - 1, false, { rebuild_row(new_row) })

	local leading_len = #new_row.indent + (new_row.has_leading and 1 or 0)
	vim.api.nvim_win_set_cursor(win, { insert_before_line, leading_len })
end

return M
