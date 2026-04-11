local treesitter = require("LYRD.layers.treesitter")

--- Helper: set up a scratch buffer with content, filetype, and an attached treesitter parser.
--- @param lines string[]
--- @param lang string
--- @return number bufnr
local function setup_buffer(lines, lang)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].filetype = lang
	-- Attach parser and force a synchronous parse so the tree is ready
	local parser = vim.treesitter.get_parser(bufnr, lang)
	parser:parse()
	return bufnr
end

--- Helper: place cursor at a 1-based line and 0-based column.
--- @param line number
--- @param col number
local function set_cursor(line, col)
	vim.api.nvim_win_set_cursor(0, { line, col })
end

-- Skip the entire file when the Lua treesitter parser is not installed.
local parser_ok = pcall(vim.treesitter.language.inspect, "lua")
if not parser_ok then
	return print("treesitter_spec: skipping — 'lua' parser not installed")
end

-- Queries used across tests -----------------------------------------------

local function_query = [[
(function_declaration name: (identifier) @name) @func
]]

local local_function_query = [[
(function_declaration name: (identifier) @name) @func
]]

-- For Lua, a local function like `local function foo()` produces a
-- `function_statement` node in some grammars and `function_declaration` in
-- others. We test both patterns to be resilient.
local assignment_function_query = [[
(assignment_statement
  (variable_list name: (identifier) @name)
  (expression_list value: (function_definition) @func_body)) @func
]]

describe("treesitter.get_match_text_at_cursor", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("returns the function name when cursor is inside a function body", function()
		bufnr = setup_buffer({
			"function hello()",
			"  return 42",
			"end",
		}, "lua")
		set_cursor(2, 3) -- inside function body

		local result = treesitter.get_match_text_at_cursor(function_query, "lua", "func", "name")

		assert.are.equal("hello", result)
	end)

	it("returns the function name when cursor is on the declaration line", function()
		bufnr = setup_buffer({
			"function greet()",
			"  print('hi')",
			"end",
		}, "lua")
		set_cursor(1, 10) -- on the function name

		local result = treesitter.get_match_text_at_cursor(function_query, "lua", "func", "name")

		assert.are.equal("greet", result)
	end)

	it("returns empty string when cursor is outside any match", function()
		bufnr = setup_buffer({
			"-- just a comment",
			"local x = 1",
		}, "lua")
		set_cursor(1, 0)

		local result = treesitter.get_match_text_at_cursor(function_query, "lua", "func", "name")

		assert.are.equal("", result)
	end)

	it("returns empty string for an empty buffer", function()
		bufnr = setup_buffer({ "" }, "lua")
		set_cursor(1, 0)

		local result = treesitter.get_match_text_at_cursor(function_query, "lua", "func", "name")

		assert.are.equal("", result)
	end)

	it("matches the correct function when multiple functions exist", function()
		bufnr = setup_buffer({
			"function first()",
			"  return 1",
			"end",
			"",
			"function second()",
			"  return 2",
			"end",
		}, "lua")
		set_cursor(6, 3) -- inside second()

		local result = treesitter.get_match_text_at_cursor(function_query, "lua", "func", "name")

		assert.are.equal("second", result)
	end)

	it("uses node_capture_name as text_capture_name when text_capture_name is nil", function()
		-- When text_capture_name is nil, the code falls back to node_capture_name for text extraction.
		-- The @func capture covers the entire function text.
		bufnr = setup_buffer({
			"function hello()",
			"  return 42",
			"end",
		}, "lua")
		set_cursor(2, 3)

		local result = treesitter.get_match_text_at_cursor(function_query, "lua", "func", nil)

		-- The result should be the full function text (the @func capture)
		assert.truthy(result:find("function hello"))
		assert.truthy(result:find("end"))
	end)

	it("returns empty string when the query has no matches in the buffer", function()
		-- Use a query that won't match anything in this buffer
		local no_match_query = [[
(for_statement) @loop
]]
		bufnr = setup_buffer({
			"local x = 1",
			"local y = 2",
		}, "lua")
		set_cursor(1, 0)

		local result = treesitter.get_match_text_at_cursor(no_match_query, "lua", "loop", nil)

		assert.are.equal("", result)
	end)
end)
