local setup = require("LYRD.setup")

local L = { name = "Mappings" }

function L.plugins(s)
	setup.plugin(s, { "folke/which-key.nvim" })
end

local function map_key(mode, lead, keys, command, documentation, options)
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

local function map_menu(lead, keys, description)
	local wk = require("which-key")
	local key_str = lead .. table.concat(keys, "")
	wk.add({
		{ key_str, group = "[" .. description .. "]" },
	})
end

local function map_ignored(lead, keys)
	local wk = require("which-key")
	local key_str = lead .. table.concat(keys, "")
	wk.add({
		{ key_str, hidden = true },
	})
end

-- Creates a set of keybindings
-- @param mappings contains the mapping definition as an array of (mode, key, command, options)
function L.keys(_, mappings, options)
	for _, mapping in ipairs(mappings) do
		local opt = mapping[4]
		if opt == nil then
			opt = options
		end
		map_key(mapping[1], nil, { mapping[2] }, mapping[3], nil, opt)
	end
end

-- Creates a set of keybindings starting with <Leader>
-- @param mappings contains the mapping definition as an array of (mode, {key1, key2 ...}, command, description, options)
function L.leader(_, mappings, options)
	for _, mapping in ipairs(mappings) do
		local opt = mapping[5]
		if opt == nil then
			opt = options
		end
		map_key(mapping[1], "Leader", mapping[2], mapping[3], mapping[4], opt)
	end
end

-- Creates a set of keybindings starting with <Space>
-- @param mappings contains the mapping definition as an array of (mode, {key1, key2 ...}, command, description, options)
function L.space(_, mappings, options)
	for _, mapping in ipairs(mappings) do
		local opt = mapping[5]
		if opt == nil then
			opt = options
		end
		map_key(mapping[1], "Space", mapping[2], mapping[3], mapping[4], opt)
	end
end

-- Creates a cascading menu for a sequence of keys starting with <Space>
-- @param mappings contains the mapping definition as an array of ({key1, key2 ...}, description)
function L.space_menu(_, mappings)
	for _, mapping in ipairs(mappings) do
		map_menu("<space>", mapping[1], mapping[2])
	end
end

-- Causes a sequence of keys starting with <Space> to be ignored and to nod appear in the menu
-- @param keys is an array of keys to be ignored in the menu
function L.leader_ignore_key(_, keys)
	map_ignored("<Leader>", keys)
end

-- Causes a sequence of keys starting with <Space> to be ignored and to nod appear in the menu
-- @param keys is an array of keys to be ignored in the menu
function L.leader_ignore_menu(_, keys)
	map_ignored("<Leader>", keys)
end

function L.settings(_)
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
