local setup = require("LYRD.setup")

local L = { name = "Mappings" }

function L.plugins(s)
	setup.plugin(s, { "folke/which-key.nvim" })
end

function L.complete(s)
	-- Updates LYRD_Settings in vim global
	local g_var = vim.g.LYRD_Settings
	g_var.mappings = s.mappings
	vim.g.LYRD_Settings = g_var

	local wk = require("which-key")
	wk.register(s.mappings.Leader, { prefix = "<leader>" })
	wk.register(s.mappings.Space, { prefix = "<Space>" })
end

local function recursive_documentation(mapping_tree, keys, documentation, depth)
	if depth == #keys then
		mapping_tree[keys[depth]] = documentation
	else
		if mapping_tree[keys[depth]] == nil then
			mapping_tree[keys[depth]] = {}
		end
		if type(mapping_tree[keys[depth]]) ~= "table" then
			local collapsedkeys = {}
			for i = 1, #keys do
				if i <= depth then
					table.insert(collapsedkeys, keys[i])
				else
					collapsedkeys[depth] = collapsedkeys[depth] .. keys[i]
				end
			end
			-- The next iteration would produce and error as the next node is not a dictionary
			recursive_documentation(mapping_tree, collapsedkeys, documentation, depth)
		else
			recursive_documentation(mapping_tree[keys[depth]], keys, documentation, depth + 1)
		end
	end
end

local function map_key(_, mode, lead, keys, command, documentation, options)
	if options == nil then
		options = { noremap = true, silent = true }
	end
	if lead ~= nil then
		lead = "<" .. lead .. ">"
	else
		lead = ""
	end
	local key_str = lead .. table.concat(keys)
	-- Adds the documentation to the native nvim keymap
	local command_str = command
    -- If the command is a Command object, then uses the command name and description
	if type(command) ~= "string" then
		command_str = "<cmd>" .. command.name .. "<CR>"
		options.desc = command.desc
	end
	options.desc = documentation or options.desc
	vim.keymap.set(mode, key_str, command_str, options)
end

local function map_menu(s, lead, keys, description)
	recursive_documentation(s.mappings[lead], keys, { name = "[" .. description .. "]" }, 1)
end

-- Creates a set of keybindings
-- @param mappings contains the mapping definition as an array of (mode, key, command, options)
function L.keys(s, mappings, options)
	for _, mapping in ipairs(mappings) do
		local opt = mapping[4]
		if opt == nil then
			opt = options
		end
		map_key(s, mapping[1], nil, { mapping[2] }, mapping[3], nil, opt)
	end
end

-- Creates a set of keybindings starting with <Leader>
-- @param mappings contains the mapping definition as an array of (mode, {key1, key2 ...}, command, description, options)
function L.leader(s, mappings, options)
	for _, mapping in ipairs(mappings) do
		local opt = mapping[5]
		if opt == nil then
			opt = options
		end
		map_key(s, mapping[1], "Leader", mapping[2], mapping[3], mapping[4], opt)
	end
end

-- Creates a set of keybindings starting with <Space>
-- @param mappings contains the mapping definition as an array of (mode, {key1, key2 ...}, command, description, options)
function L.space(s, mappings, options)
	for _, mapping in ipairs(mappings) do
		local opt = mapping[5]
		if opt == nil then
			opt = options
		end
		map_key(s, mapping[1], "Space", mapping[2], mapping[3], mapping[4], opt)
	end
end

-- Creates a cascading menu for a sequence of keys starting with <Space>
-- @param mappings contains the mapping definition as an array of ({key1, key2 ...}, description)
function L.space_menu(s, mappings)
	for _, mapping in ipairs(mappings) do
		map_menu(s, "Space", mapping[1], mapping[2])
	end
end

-- Causes a sequence of keys starting with <Space> to be ignored and to nod appear in the menu
-- @param keys is an array of keys to be ignored in the menu
function L.leader_ignore_key(s, keys)
	recursive_documentation(s.mappings["Leader"], keys, "which_key_ignore", 1)
end

-- Causes a sequence of keys starting with <Space> to be ignored and to nod appear in the menu
-- @param keys is an array of keys to be ignored in the menu
function L.leader_ignore_menu(s, keys)
	recursive_documentation(s.mappings["Leader"], keys, { name = "which_key_ignore" }, 1)
end

function L.settings(s)
	s.mappings = { Leader = {}, Space = {} }
	require("which-key").setup({
		icons = {
			group = "", -- symbol prepended to a group
		},
		layout = {
			height = { min = 1, max = 25 }, -- min and max height of the columns
			width = { min = 20, max = 50 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
			align = "center", -- align columns left, center or right
		},
		-- ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
	})
end

return L
