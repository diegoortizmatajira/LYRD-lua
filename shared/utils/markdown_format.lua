-- Toggles inline emphasis markers, a blockquote prefix, and a fenced code
-- block around the current visual selection, falling back to the whole
-- current line when there's no selection. Each toggle checks whether the
-- target already carries the marker and strips it if so, otherwise it
-- wraps/prefixes it.

local utils = require("LYRD.shared.utils")

local M = {}

--- Leaves Visual mode. Buffer edits made via the API don't do this on their
--- own, so without it the selection stays highlighted after a toggle runs.
local function exit_visual_mode()
	vim.cmd("normal! \27")
end

--- Returns the range to operate on: the current visual selection, or, if
--- there isn't one, the whole current line (mirroring how "V" linewise
--- selection is reported by `get_visual_range`).
---@param bufnr integer
---@return integer start_row, integer start_col, integer end_row, integer end_col
local function get_target_range(bufnr)
	local start_row, start_col, end_row, end_col = utils.get_visual_range(bufnr)
	if start_row then
		return start_row, start_col, end_row, end_col
	end

	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
	return lnum, 0, lnum, #line - 1
end

--- Toggles a marker pair around the current visual selection's text, or the
--- whole current line when there's no selection. Leading/trailing spaces and
--- tabs are left outside the markers, since CommonMark emphasis delimiters
--- can't have whitespace right next to them -- e.g. a line ending in trailing
--- spaces would otherwise get its closing marker placed after them, where it
--- doesn't count as emphasis.
---@param start_marker string
---@param end_marker string
local function toggle_wrap(start_marker, end_marker)
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = get_target_range(bufnr)

	local text =
		table.concat(vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col + 1, {}), "\n")

	local leading_ws = text:match("^[ \t]*")
	local trailing_ws = text:match("[ \t]*$")
	local core = text:sub(#leading_ws + 1, #text - #trailing_ws)

	local stripped = core:match("^" .. vim.pesc(start_marker) .. "(.-)" .. vim.pesc(end_marker) .. "$")
	local new_core = stripped or (start_marker .. core .. end_marker)
	local result = leading_ws .. new_core .. trailing_ws

	vim.api.nvim_buf_set_text(
		bufnr,
		start_row,
		start_col,
		end_row,
		end_col + 1,
		vim.split(result, "\n", { plain = true })
	)
	exit_visual_mode()
end

--- Toggles "**bold**" around the current visual selection.
function M.toggle_bold()
	toggle_wrap("**", "**")
end

--- Toggles "_italic_" around the current visual selection.
function M.toggle_italic()
	toggle_wrap("_", "_")
end

--- Toggles "<u>underline</u>" around the current visual selection.
function M.toggle_underline()
	toggle_wrap("<u>", "</u>")
end

--- Toggles "~~strikethrough~~" around the current visual selection.
function M.toggle_strikethrough()
	toggle_wrap("~~", "~~")
end

--- Toggles "==highlight==" around the current visual selection.
function M.toggle_highlight()
	toggle_wrap("==", "==")
end

--- Toggles "<sup>superscript</sup>" around the current visual selection.
function M.toggle_superscript()
	toggle_wrap("<sup>", "</sup>")
end

--- Toggles "<sub>subscript</sub>" around the current visual selection.
function M.toggle_subscript()
	toggle_wrap("<sub>", "</sub>")
end

--- Toggles "`inline code`" around the current visual selection.
function M.toggle_inline_code()
	toggle_wrap("`", "`")
end

--- Toggles a "> " blockquote prefix on every line of the current visual
--- selection, or the current line when there's no selection. Blank lines are
--- left untouched so a quoted paragraph followed by a blank separator line
--- isn't turned into "> ".
function M.toggle_quote_block()
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, _, end_row = get_target_range(bufnr)

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
	local all_quoted = true
	for _, line in ipairs(lines) do
		if line ~= "" and not line:match("^> ?") then
			all_quoted = false
			break
		end
	end

	local result = {}
	for i, line in ipairs(lines) do
		if line == "" then
			result[i] = line
		elseif all_quoted then
			result[i] = (line:gsub("^> ?", ""))
		else
			result[i] = "> " .. line
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, result)
	exit_visual_mode()
end

--- Toggles a fenced code block ("```") around every line of the current
--- visual selection, or the current line when there's no selection.
function M.toggle_code_block()
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, _, end_row = get_target_range(bufnr)

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
	local is_fenced = #lines >= 2 and lines[1]:match("^```") and lines[#lines] == "```"

	local result
	if is_fenced then
		result = {}
		for i = 2, #lines - 1 do
			result[#result + 1] = lines[i]
		end
	else
		result = { "```" }
		vim.list_extend(result, lines)
		table.insert(result, "```")
	end

	vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, result)
	exit_visual_mode()
end

return M
