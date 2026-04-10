local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local utils = require("LYRD.shared.utils")

---@class LYRD.layer.Treesitter: LYRD.setup.Module
local L = {
	name = "Treesitter Parsing",
	unskippable = true,
	required = {
		"query",
		"regex",
		"bash",
		"fish",
		"diff",
		"editorconfig",
		"nginx",
		"pem",
		"tmux",
		"vim",
		"vimdoc",
	},
}

function L.plugins()
	setup.plugin({
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "main",
			build = ":TSUpdate",
		},
		{ -- Additional text objects via treesitter
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
		},
		{
			"ThePrimeagen/refactoring.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {
				-- prompt for return type
				prompt_func_return_type = { go = true, cpp = true, c = true, java = true },
				-- prompt for function parameters
				prompt_func_param_type = { go = true, cpp = true, c = true, java = true },
			},
			config = function(_, opts)
				require("refactoring").setup(opts)
				require("telescope").load_extension("refactoring")
			end,
		},
	})
end

--- Ensure that the parsers are installed
--- @param parsers string|string[] List of parsers to ensure are installed
function L.ensureParser(parsers)
	if type(parsers) == "string" then
		parsers = { parsers }
	end
	for _, parser in ipairs(parsers) do
		if not vim.tbl_contains(L.required, parser) then
			table.insert(L.required, parser)
		end
	end
end

--- Retrieves matches from a parsed Treesitter query based on the specified parameters.
---
--- @param query_string string The Treesitter query string to be parsed.
--- @param lang string The language of the current buffer.
--- @param filter_func? fun(match: TSNode[], captures: string[]):boolean A function to filter matches. Receives the match and captures as arguments.
--- @param map_func? fun(match: TSNode[], captures: string[]):any A function to transform the captured node. Receives the match and captures as arguments.
--- @param max_results number|nil The maximum number of results to return.
---
--- @return table A list of captured nodes that match the query, filtered and transformed as specified.
function L.get_matches(query_string, lang, filter_func, map_func, max_results)
	local bufnr = vim.api.nvim_get_current_buf()

	-- Parse the query
	local query = vim.treesitter.query.parse(lang, query_string)

	-- Get the root syntax tree node
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
	if not ok or not parser then
		return {}
	end
	local trees = parser:parse()
	local root = trees[1] and trees[1]:root()
	if not root then
		return {}
	end

	local results = {}
	local count = 0
	-- Iterate over matches
	for _, match, _ in query:iter_matches(root, bufnr, 0, -1) do
		if not filter_func or filter_func(match, query.captures) then
			local mapped_result = map_func and map_func(match, query.captures) or match
			if mapped_result then
				table.insert(results, mapped_result)
				count = count + 1
				if max_results and count >= max_results then
					break
				end
			end
		end
	end
	return results
end

--- Gets the text of all captures that match the query
--- @param query_string string The treesitter query string
--- @param lang string The language of the current buffer
--- @param node_capture_name string The name of the capture that contains the node to check
--- @param text_capture_name string|nil The name of the capture that contains the text to return (if different from node_capture_name)
--- @param filter_func? fun(match: TSNode[], captures: string[]):boolean A function to filter matches. Receives the match and captures as arguments.
--- @param max_results number|nil The maximum number of results to return.
--- @return string[] A list of texts of the captures that match the query
function L.get_match_texts(query_string, lang, node_capture_name, text_capture_name, filter_func, max_results)
	if not text_capture_name then
		text_capture_name = node_capture_name
	end
	return L.get_matches(query_string, lang, filter_func, function(match, captures)
		-- Return the text of the text capture
		local text_capture_index = utils.index_of(captures, text_capture_name)
		if not text_capture_index then
			return nil
		end
		local captured_node = match[text_capture_index][1]
		local bufnr = vim.api.nvim_get_current_buf()
		return vim.treesitter.get_node_text(captured_node, bufnr)
	end, max_results)
end

--- Gets the text of the capture at the cursor position
--- @param query_string string The treesitter query string
--- @param lang string The language of the current buffer
--- @param node_capture_name string The name of the capture that contains the node to check
--- @param text_capture_name string|nil The name of the capture that contains the text to return (if different from node_capture_name)
--- @return string The text of the capture at the cursor position, or an empty string if not found
function L.get_match_text_at_cursor(query_string, lang, node_capture_name, text_capture_name)
	local node_at_cursor = vim.treesitter.get_node()
	if not node_at_cursor then
		return ""
	end
	local matches = L.get_match_texts(
		query_string,
		lang,
		node_capture_name,
		text_capture_name,
		function(match, captures)
			-- Check if the node at cursor is within the captured node
			local capture_index = utils.index_of(captures, node_capture_name)
			if not capture_index then
				return false
			end
			local captured_node = match[capture_index][1]
			return captured_node == node_at_cursor or vim.treesitter.is_ancestor(captured_node, node_at_cursor)
		end,
		1
	)
	return matches and matches[1] or ""
end

function L.settings()
	-- Install required parsers
	require("nvim-treesitter").install(L.required)

	-- Textobjects configuration
	require("nvim-treesitter-textobjects").setup({
		select = {
			lookahead = true,
		},
		move = {
			set_jumps = true,
		},
	})

	-- Textobject select keymaps
	local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
	for _, mapping in ipairs({
		{ "aa", "@parameter.outer" },
		{ "ia", "@parameter.inner" },
		{ "af", "@function.outer" },
		{ "if", "@function.inner" },
		{ "ac", "@class.outer" },
		{ "ic", "@class.inner" },
	}) do
		vim.keymap.set({ "x", "o" }, mapping[1], function()
			select_textobject(mapping[2], "textobjects")
		end)
	end

	-- Textobject move keymaps
	local move = require("nvim-treesitter-textobjects.move")
	for _, mapping in ipairs({
		{ "]m", move.goto_next_start, "@function.outer" },
		{ "]]", move.goto_next_start, "@class.outer" },
		{ "]M", move.goto_next_end, "@function.outer" },
		{ "][", move.goto_next_end, "@class.outer" },
		{ "[m", move.goto_previous_start, "@function.outer" },
		{ "[[", move.goto_previous_start, "@class.outer" },
		{ "[M", move.goto_previous_end, "@function.outer" },
		{ "[]", move.goto_previous_end, "@class.outer" },
	}) do
		vim.keymap.set({ "n", "x", "o" }, mapping[1], function()
			mapping[2](mapping[3], "textobjects")
		end)
	end

	-- Textobject swap keymaps
	local swap = require("nvim-treesitter-textobjects.swap")
	vim.keymap.set("n", "<leader>Sa", function()
		swap.swap_next("@parameter.inner")
	end)
	vim.keymap.set("n", "<leader>SA", function()
		swap.swap_previous("@parameter.inner")
	end)

	local wrap = require("LYRD.layers.commands").wrap
	commands.implement("*", {
		{ cmd.LYRDCodeRefactor, wrap(require("refactoring").select_refactor) },
		{ cmd.LYRDViewTreeSitterPlayground, ":InspectTree" },
	})
end

return L
