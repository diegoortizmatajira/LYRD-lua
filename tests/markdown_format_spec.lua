local markdown_format = require("LYRD.shared.utils.markdown_format")

--- Helper: create a scratch buffer with the given lines and make it current.
--- @param lines string[]
--- @return integer bufnr
local function make_buffer(lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	return bufnr
end

--- Helper: read all lines from a buffer.
--- @param bufnr integer
--- @return string[]
local function get_lines(bufnr)
	return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

--- Helper: enter Visual mode ("v", "V", or "\22"), select from `from` to `to`
--- (1-based row, 0-based col, per `nvim_win_set_cursor`), run `fn`, and leave
--- Visual mode afterwards.
--- @param mode_key string
--- @param from integer[]
--- @param to integer[]
--- @param fn fun()
local function with_selection(mode_key, from, to, fn)
	vim.cmd("normal! \27")
	vim.api.nvim_win_set_cursor(0, from)
	vim.cmd("normal! " .. mode_key)
	vim.api.nvim_win_set_cursor(0, to)
	fn()
	vim.cmd("normal! \27")
end

describe("markdown_format.toggle_bold", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in ** markers", function()
		bufnr = make_buffer({ "hello world" })

		with_selection("v", { 1, 0 }, { 1, 4 }, markdown_format.toggle_bold)

		assert.are.same({ "**hello** world" }, get_lines(bufnr))
	end)

	it("strips ** markers when the selection is already bold", function()
		bufnr = make_buffer({ "**hello** world" })

		with_selection("v", { 1, 0 }, { 1, 8 }, markdown_format.toggle_bold)

		assert.are.same({ "hello world" }, get_lines(bufnr))
	end)

	it("falls back to the whole current line when there's no selection", function()
		bufnr = make_buffer({ "hello world" })
		vim.cmd("normal! \27")
		vim.api.nvim_win_set_cursor(0, { 1, 3 })

		markdown_format.toggle_bold()

		assert.are.same({ "**hello world**" }, get_lines(bufnr))
	end)

	it("leaves trailing whitespace outside the closing marker", function()
		bufnr = make_buffer({ "hello world   " })
		vim.cmd("normal! \27")
		vim.api.nvim_win_set_cursor(0, { 1, 0 })

		markdown_format.toggle_bold()

		assert.are.same({ "**hello world**   " }, get_lines(bufnr))
	end)

	it("leaves leading whitespace/tabs outside the opening marker", function()
		bufnr = make_buffer({ "\thello world\t  " })
		vim.cmd("normal! \27")
		vim.api.nvim_win_set_cursor(0, { 1, 0 })

		markdown_format.toggle_bold()

		assert.are.same({ "\t**hello world**\t  " }, get_lines(bufnr))
	end)

	it("leaves Visual mode after applying the toggle", function()
		bufnr = make_buffer({ "hello world" })
		vim.cmd("normal! \27")
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		vim.cmd("normal! v")
		vim.api.nvim_win_set_cursor(0, { 1, 4 })

		markdown_format.toggle_bold()

		assert.are.equal("n", vim.api.nvim_get_mode().mode)
	end)

	it("removes only the bold layer from a nested bold+italic selection", function()
		bufnr = make_buffer({ "_**text**_" })

		with_selection("v", { 1, 0 }, { 1, 9 }, markdown_format.toggle_bold)

		assert.are.same({ "_text_" }, get_lines(bufnr))
	end)

	it("nests a new bold layer around already-formatted text instead of duplicating markers", function()
		bufnr = make_buffer({ "_text_" })

		with_selection("v", { 1, 0 }, { 1, 5 }, markdown_format.toggle_bold)

		local line = get_lines(bufnr)[1]
		assert.truthy(line:find("**", 1, true))
		assert.is_falsy(line:find("****", 1, true))
	end)
end)

describe("markdown_format.toggle_italic", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in _ markers", function()
		bufnr = make_buffer({ "hello world" })

		with_selection("v", { 1, 6 }, { 1, 10 }, markdown_format.toggle_italic)

		assert.are.same({ "hello _world_" }, get_lines(bufnr))
	end)

	it("strips _ markers when the selection is already italic", function()
		bufnr = make_buffer({ "hello _world_" })

		with_selection("v", { 1, 6 }, { 1, 12 }, markdown_format.toggle_italic)

		assert.are.same({ "hello world" }, get_lines(bufnr))
	end)

	it("removes only the italic layer from a nested bold+italic selection", function()
		bufnr = make_buffer({ "_**text**_" })

		with_selection("v", { 1, 0 }, { 1, 9 }, markdown_format.toggle_italic)

		assert.are.same({ "**text**" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_underline", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in <u></u> tags", function()
		bufnr = make_buffer({ "hello world" })

		with_selection("v", { 1, 0 }, { 1, 4 }, markdown_format.toggle_underline)

		assert.are.same({ "<u>hello</u> world" }, get_lines(bufnr))
	end)

	it("strips <u></u> tags when the selection is already underlined", function()
		bufnr = make_buffer({ "<u>hello</u> world" })

		with_selection("v", { 1, 0 }, { 1, 11 }, markdown_format.toggle_underline)

		assert.are.same({ "hello world" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_strikethrough", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in ~~ markers", function()
		bufnr = make_buffer({ "hello world" })

		with_selection("v", { 1, 0 }, { 1, 4 }, markdown_format.toggle_strikethrough)

		assert.are.same({ "~~hello~~ world" }, get_lines(bufnr))
	end)

	it("strips ~~ markers when the selection is already struck through", function()
		bufnr = make_buffer({ "~~hello~~ world" })

		with_selection("v", { 1, 0 }, { 1, 8 }, markdown_format.toggle_strikethrough)

		assert.are.same({ "hello world" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_highlight", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in == markers", function()
		bufnr = make_buffer({ "hello world" })

		with_selection("v", { 1, 0 }, { 1, 4 }, markdown_format.toggle_highlight)

		assert.are.same({ "==hello== world" }, get_lines(bufnr))
	end)

	it("strips == markers when the selection is already highlighted", function()
		bufnr = make_buffer({ "==hello== world" })

		with_selection("v", { 1, 0 }, { 1, 8 }, markdown_format.toggle_highlight)

		assert.are.same({ "hello world" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_superscript", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in <sup></sup> tags", function()
		bufnr = make_buffer({ "x2 hint" })

		with_selection("v", { 1, 1 }, { 1, 1 }, markdown_format.toggle_superscript)

		assert.are.same({ "x<sup>2</sup> hint" }, get_lines(bufnr))
	end)

	it("strips <sup></sup> tags when the selection already has them", function()
		bufnr = make_buffer({ "x<sup>2</sup> hint" })

		with_selection("v", { 1, 1 }, { 1, 12 }, markdown_format.toggle_superscript)

		assert.are.same({ "x2 hint" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_subscript", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in <sub></sub> tags", function()
		bufnr = make_buffer({ "H2O" })

		with_selection("v", { 1, 1 }, { 1, 1 }, markdown_format.toggle_subscript)

		assert.are.same({ "H<sub>2</sub>O" }, get_lines(bufnr))
	end)

	it("strips <sub></sub> tags when the selection already has them", function()
		bufnr = make_buffer({ "H<sub>2</sub>O" })

		with_selection("v", { 1, 1 }, { 1, 12 }, markdown_format.toggle_subscript)

		assert.are.same({ "H2O" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_inline_code", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the visual selection in backticks", function()
		bufnr = make_buffer({ "run foo() now" })

		with_selection("v", { 1, 4 }, { 1, 8 }, markdown_format.toggle_inline_code)

		assert.are.same({ "run `foo()` now" }, get_lines(bufnr))
	end)

	it("strips backticks when the selection is already inline code", function()
		bufnr = make_buffer({ "run `foo()` now" })

		with_selection("v", { 1, 4 }, { 1, 10 }, markdown_format.toggle_inline_code)

		assert.are.same({ "run foo() now" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_quote_block", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("prefixes every selected line with '> '", function()
		bufnr = make_buffer({ "hello world", "second line" })

		with_selection("V", { 1, 0 }, { 2, 0 }, markdown_format.toggle_quote_block)

		assert.are.same({ "> hello world", "> second line" }, get_lines(bufnr))
	end)

	it("strips the '> ' prefix when the selection is already quoted", function()
		bufnr = make_buffer({ "> hello world", "> second line" })

		with_selection("V", { 1, 0 }, { 2, 0 }, markdown_format.toggle_quote_block)

		assert.are.same({ "hello world", "second line" }, get_lines(bufnr))
	end)

	it("leaves blank lines untouched", function()
		bufnr = make_buffer({ "hello world", "", "second line" })

		with_selection("V", { 1, 0 }, { 3, 0 }, markdown_format.toggle_quote_block)

		assert.are.same({ "> hello world", "", "> second line" }, get_lines(bufnr))
	end)

	it("falls back to the current line when there's no selection", function()
		bufnr = make_buffer({ "hello world", "second line" })
		vim.cmd("normal! \27")
		vim.api.nvim_win_set_cursor(0, { 2, 0 })

		markdown_format.toggle_quote_block()

		assert.are.same({ "hello world", "> second line" }, get_lines(bufnr))
	end)
end)

describe("markdown_format.toggle_code_block", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("wraps the selected lines in a ``` fence", function()
		bufnr = make_buffer({ "echo hello", "second line" })

		with_selection("V", { 1, 0 }, { 2, 0 }, markdown_format.toggle_code_block)

		assert.are.same({ "```", "echo hello", "second line", "```" }, get_lines(bufnr))
	end)

	it("strips the ``` fence when the selection already includes it", function()
		bufnr = make_buffer({ "```", "echo hello", "second line", "```" })

		with_selection("V", { 1, 0 }, { 4, 0 }, markdown_format.toggle_code_block)

		assert.are.same({ "echo hello", "second line" }, get_lines(bufnr))
	end)

	it("falls back to the current line when there's no selection", function()
		bufnr = make_buffer({ "echo hello" })
		vim.cmd("normal! \27")
		vim.api.nvim_win_set_cursor(0, { 1, 0 })

		markdown_format.toggle_code_block()

		assert.are.same({ "```", "echo hello", "```" }, get_lines(bufnr))
	end)
end)
