---@module "LYRD.layers.mappings"
---@Author: Diego Ortiz

local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")
local c = require("LYRD.layers.commands").command_shortcut

local L = { name = "Mappings" }

---@class LYRD.mappings.standard_mapping
---@field [1] string contains the key
---@field [2] Command contains the command

---@class LYRD.mappings.header_mapping
---@field key string contains the key
---@field title string title for the menu
---@field items LYRD.mappings.mapping[]
---@field type "header" | "submode" type of header
---@field icon? string
---
---@alias LYRD.mappings.mapping LYRD.mappings.header_mapping|LYRD.mappings.standard_mapping

function L.plugins(s)
	setup.plugin(s, {
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				icons = {
					group = "", -- symbol prepended to a group
				},
				layout = {
					height = { min = 1, max = 25 }, -- min and max height of the columns
					width = { min = 20, max = 50 }, -- min and max width of the columns
					spacing = 3, -- spacing between columns
					align = "center", -- align columns left, center or right
				},
				-- win = {
				-- 	border = "solid",
				-- },
			},
			keys = {
				{
					"<leader>?",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
		{
			"nvimtools/hydra.nvim",
			opts = {
				hint = {
					float_opts = {
						border = "rounded",
					},
				},
			},
		},
	})
end

---Creates a keybinding
---@param mode string
---@param lead string|nil
---@param keys string|table
---@param command string|Command
---@param documentation? string
---@param options? table
local function map_key(mode, lead, keys, command, documentation, options)
	local wk = require("which-key")
	local entry = options or { noremap = true, silent = true }
	if lead then
		lead = "<" .. lead .. ">"
	else
		lead = ""
	end
	local key_str = lead
	if type(keys) == "string" then
		key_str = key_str .. keys
	else
		key_str = key_str .. table.concat(keys)
	end
	-- Adds the documentation to the native nvim keymap
	local command_str = command
	local desc_str = entry.desc
	local icon_str = nil
	-- If the command is a Command object, then uses the command name and description
	if type(command) ~= "string" then
		command_str = command:as_vim_command(mode)
		desc_str = command.desc
		if type(command.icon) == "string" then
			icon_str = icons.icon(command.icon)
		else
			icon_str = command.icon
		end
	end
	table.insert(entry, 1, key_str)
	table.insert(entry, 2, command_str)
	entry.desc = documentation or desc_str
	entry.mode = mode
	entry.icon = icon_str
	wk.add({ entry })
end

---Creates a keybinding for a menu
---@param keys string
---@param title string
---@param icon? string
local function map_menu(keys, title, icon)
	local wk = require("which-key")
	if type(icon) == "string" then
		icon_str = icons.icon(icon)
	else
		icon_str = icon
	end
	wk.add({ { keys, group = "[" .. title .. "]", icon = icon_str } })
end

---Creates a set of keybindings
---@param mappings {[1]: string|string[], [2]:string, [3]:string|function|Command, [4]: table}[] contains the mapping definition as an array of (mode, key, command, options)
function L.keys(_, mappings, options)
	for _, mapping in ipairs(mappings) do
		local mode, key, command, opt = unpack(mapping)
		if opt == nil then
			opt = options
		end
		map_key(mode, nil, { key }, command, nil, opt)
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

--- Creates a menu
--- @param prefix string
--- @param items LYRD.mappings.mapping[]
function L.create_menu(prefix, items)
	local Hydra = require("hydra")
	for _, item in ipairs(items) do
		if item.type == "header" then
			map_menu(prefix .. item.key, item.title, item.icon)
			L.create_menu(prefix .. item.key, item.items)
		elseif item.type == "submode" then
			-- Creates a submode
			map_menu(prefix .. item.key, item.title, item.icon)
			heads = {}
			for _, mode_item in ipairs(item.items) do
				local submode_key, command = unpack(mode_item)
				if type(command) == "string" then
					table.insert(heads, { submode_key, command })
				else
					table.insert(heads, { submode_key, c(command.name), { desc = command.desc } })
				end
			end
			table.insert(heads, { "<Esc>", nil, { exit = true, desc = "Exit" } })
			Hydra({
				name = item.title,
				mode = "n",
				body = prefix .. item.key,
				hint = item.title,
				config = {
					color = "amaranth",
					invoke_on_body = true,
				},
				heads = heads,
			})
		elseif #item == 2 then
			-- Map a menu item with its sequence of keys
			local key, command = unpack(item)
			map_key("n", nil, prefix .. key, command)
		end
	end
end

function L.create_filetype_menu()
	-- Create an autocommand group
	local group = vim.api.nvim_create_augroup("PythonMappings", { clear = true })
	-- Define the autocommand
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		group = group,
		callback = function()
			-- Set key mappings for the buffer
			local opts = { noremap = true, silent = true }
			vim.api.nvim_buf_set_keymap(0, "n", "<leader>r", ":!python3 %<CR>", opts)
			vim.api.nvim_buf_set_keymap(0, "n", "<leader>t", ":!pytest %<CR>", opts)
		end,
	})
end

--- Creates a menu header
--- @param key string
--- @param title string
--- @param items LYRD.mappings.mapping[]
--- @return LYRD.mappings.header_mapping
function L.menu_header(key, title, items, icon)
	---@type LYRD.mappings.header_mapping
	return {
		key = key,
		title = title,
		items = items,
		type = "header",
		icon = icon,
	}
end

--- Creates a submode header
--- @param key string
--- @param title string
--- @param items LYRD.mappings.mapping[]
--- @return LYRD.mappings.header_mapping
function L.submode_header(key, title, items, icon)
	---@type LYRD.mappings.header_mapping
	return {
		key = key,
		title = title,
		items = items,
		type = "submode",
		icon = icon,
	}
end

return L
