local generator = require("LYRD.layers.lang.go-generator")

-- Save originals
local orig_fnamemodify = vim.fn.fnamemodify
local orig_notify = vim.notify
local orig_ui_select = vim.ui.select
local orig_ui_input = vim.ui.input

local notify_calls = {}

local function mock_notify()
	notify_calls = {}
	vim.notify = function(msg, level)
		table.insert(notify_calls, { msg = msg, level = level })
	end
end

local function restore_mocks()
	vim.fn.fnamemodify = orig_fnamemodify
	vim.notify = orig_notify
	vim.ui.select = orig_ui_select
	vim.ui.input = orig_ui_input
end

-- ── get_package tests (no treesitter needed) ──────────────────────────

describe("go-generator.get_package", function()
	after_each(function()
		restore_mocks()
	end)

	it("returns the immediate parent directory name", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" and path == "/home/user/projects/myapp/handlers/service.go" then
				return "/home/user/projects/myapp/handlers"
			end
			if modifier == ":t" and path == "/home/user/projects/myapp/handlers" then
				return "handlers"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/home/user/projects/myapp/handlers/service.go")

		assert.are.equal("handlers", result)
	end)

	it("replaces hyphens with underscores in the package name", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/home/user/projects/my-service"
			end
			if modifier == ":t" then
				return "my-service"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/home/user/projects/my-service/main.go")

		assert.are.equal("my_service", result)
	end)

	it("handles multiple hyphens in the directory name", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/projects/my-cool-pkg"
			end
			if modifier == ":t" then
				return "my-cool-pkg"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/projects/my-cool-pkg/file.go")

		assert.are.equal("my_cool_pkg", result)
	end)

	it("sends an INFO notification with the package name", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/projects/utils"
			end
			if modifier == ":t" then
				return "utils"
			end
			return orig_fnamemodify(path, modifier)
		end

		generator.get_package("/projects/utils/helpers.go")

		local info = vim.tbl_filter(function(n)
			return n.level == vim.log.levels.INFO
		end, notify_calls)
		assert.are.equal(1, #info)
		assert.truthy(info[1].msg:find("utils"))
	end)

	it("returns a simple name when the file is at the root of a package", function()
		mock_notify()
		vim.fn.fnamemodify = function(path, modifier)
			if modifier == ":h" then
				return "/cmd"
			end
			if modifier == ":t" then
				return "cmd"
			end
			return orig_fnamemodify(path, modifier)
		end

		local result = generator.get_package("/cmd/main.go")

		assert.are.equal("cmd", result)
	end)
end)

-- ── Treesitter-dependent tests ────────────────────────────────────────

-- Skip if the Go treesitter parser is not installed
local parser_ok = pcall(vim.treesitter.language.inspect, "go")
if not parser_ok then
	print("go_generator_spec: skipping treesitter tests — 'go' parser not installed")
	return
end

--- Helper: create a scratch buffer with Go content and attach a treesitter parser.
--- @param lines string[]
--- @return number bufnr
local function setup_go_buffer(lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].filetype = "go"
	local parser = vim.treesitter.get_parser(bufnr, "go")
	parser:parse()
	return bufnr
end

--- Helper: read all lines from a buffer.
--- @param bufnr number
--- @return string[]
local function get_buf_lines(bufnr)
	return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

describe("go-generator.generate_getters", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		restore_mocks()
	end)

	it("generates getter methods for all fields in a single struct", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type User struct {",
			"	name string",
			"	age  int",
			"}",
		})
		-- Place cursor at the end of the file
		vim.api.nvim_win_set_cursor(0, { 6, 0 })

		mock_notify()
		-- Mock vim.ui.select to auto-pick the only struct
		-- (with a single struct, select_structure calls callback directly)

		generator.generate_getters(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("func %(u User%) Name%(%) string"))
		assert.truthy(content:find("func %(u User%) Age%(%) int"))
	end)

	it("uses first letter of struct name lowercased as receiver", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Product struct {",
			"	price float64",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 5, 0 })
		mock_notify()

		generator.generate_getters(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("func %(p Product%)"))
	end)

	it("capitalizes the first letter of field name for the getter name", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Item struct {",
			"	value int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 5, 0 })
		mock_notify()

		generator.generate_getters(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("Value%(%)"))
	end)

	it("prompts selection when multiple structs exist", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type First struct {",
			"	a int",
			"}",
			"",
			"type Second struct {",
			"	b string",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 9, 0 })
		mock_notify()

		-- Mock vim.ui.select to pick "Second"
		vim.ui.select = function(items, opts, cb)
			assert.are.equal(2, #items)
			cb("Second")
		end

		generator.generate_getters(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		-- Should only have getters for Second
		assert.truthy(content:find("func %(s Second%) B%(%) string"))
		assert.is_falsy(content:find("func %(f First%)"))
	end)

	it("does nothing when callback receives nil (user cancels selection)", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type A struct {",
			"	x int",
			"}",
			"",
			"type B struct {",
			"	y int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 9, 0 })
		mock_notify()

		vim.ui.select = function(_, _, cb)
			cb(nil)
		end

		local lines_before = get_buf_lines(bufnr)
		generator.generate_getters(bufnr)
		local lines_after = get_buf_lines(bufnr)

		assert.are.same(lines_before, lines_after)
	end)
end)

describe("go-generator.generate_setters", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		restore_mocks()
	end)

	it("generates setter methods for all fields in a struct", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type User struct {",
			"	name string",
			"	age  int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 6, 0 })
		mock_notify()

		generator.generate_setters(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("func %(u User%) SetName%(value string%)"))
		assert.truthy(content:find("func %(u User%) SetAge%(value int%)"))
	end)

	it("assigns the value parameter to the field", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Config struct {",
			"	timeout int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 5, 0 })
		mock_notify()

		generator.generate_setters(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("c%.timeout = value"))
	end)

	it("does nothing when user cancels struct selection", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type A struct {",
			"	x int",
			"}",
			"",
			"type B struct {",
			"	y int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 9, 0 })
		mock_notify()

		vim.ui.select = function(_, _, cb)
			cb(nil)
		end

		local lines_before = get_buf_lines(bufnr)
		generator.generate_setters(bufnr)
		local lines_after = get_buf_lines(bufnr)

		assert.are.same(lines_before, lines_after)
	end)
end)

describe("go-generator.generate_mapping", function()
	local bufnr

	after_each(function()
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		restore_mocks()
	end)

	it("generates mapping lines with prefixes and operator", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Record struct {",
			"	id   int",
			"	name string",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 6, 0 })
		mock_notify()

		-- Mock all three vim.ui.input calls in sequence
		local input_call = 0
		vim.ui.input = function(opts, cb)
			input_call = input_call + 1
			if input_call == 1 then
				cb("target")
			elseif input_call == 2 then
				cb("source")
			elseif input_call == 3 then
				cb("=")
			end
		end

		generator.generate_mapping(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("target%.id = source%.id"))
		assert.truthy(content:find("target%.name = source%.name"))
	end)

	it("generates mapping without prefixes when empty strings are given", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Point struct {",
			"	x int",
			"	y int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 6, 0 })
		mock_notify()

		local input_call = 0
		vim.ui.input = function(_, cb)
			input_call = input_call + 1
			if input_call == 1 then
				cb("") -- no target prefix
			elseif input_call == 2 then
				cb("") -- no source prefix
			elseif input_call == 3 then
				cb(":=")
			end
		end

		generator.generate_mapping(bufnr)

		local lines = get_buf_lines(bufnr)
		local content = table.concat(lines, "\n")
		assert.truthy(content:find("x := x"))
		assert.truthy(content:find("y := y"))
	end)

	it("does nothing when user cancels struct selection", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type A struct {",
			"	x int",
			"}",
			"",
			"type B struct {",
			"	y int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 9, 0 })
		mock_notify()

		vim.ui.select = function(_, _, cb)
			cb(nil)
		end

		local lines_before = get_buf_lines(bufnr)
		generator.generate_mapping(bufnr)
		local lines_after = get_buf_lines(bufnr)

		assert.are.same(lines_before, lines_after)
	end)

	it("does nothing when user cancels target prefix input", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Item struct {",
			"	val int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 5, 0 })
		mock_notify()

		vim.ui.input = function(_, cb)
			cb(nil) -- user presses Esc
		end

		local lines_before = get_buf_lines(bufnr)
		generator.generate_mapping(bufnr)
		local lines_after = get_buf_lines(bufnr)

		assert.are.same(lines_before, lines_after)
	end)

	it("does nothing when user cancels source prefix input", function()
		bufnr = setup_go_buffer({
			"package main",
			"",
			"type Item struct {",
			"	val int",
			"}",
		})
		vim.api.nvim_win_set_cursor(0, { 5, 0 })
		mock_notify()

		local input_call = 0
		vim.ui.input = function(_, cb)
			input_call = input_call + 1
			if input_call == 1 then
				cb("target")
			else
				cb(nil) -- cancel on source prefix
			end
		end

		local lines_before = get_buf_lines(bufnr)
		generator.generate_mapping(bufnr)
		local lines_after = get_buf_lines(bufnr)

		assert.are.same(lines_before, lines_after)
	end)
end)
