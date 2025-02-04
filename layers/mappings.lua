---@module "LYRD.layers.mappings"
---@Author: Diego Ortiz

local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")
local c = require("LYRD.layers.commands").command_shortcut

local L = { name = "Mappings", filetype_specific_leader_prefix = "." }

---@class LYRD.mappings.standard_mapping
---@field [1] string contains the key
---@field [2] Command contains the command
---@field [3]? string[] contains any additional modes to create the mapping

---@class LYRD.mappings.header_mapping
---@field key string contains the key
---@field title string|fun():string title for the menu
---@field items LYRD.mappings.mapping[]
---@field type "header" | "submode" type of header
---@field icon? string|fun() icon for the menu
---@field additional_modes? string[] contains any additional modes to create the mapping
---@field accept_foreign_keys? boolean For submodes, if true, the submode will accept keys from the parent mode

---@class LYRD.mappings.mapping_details
---@field command string
---@field desc string|fun():string
---@field icon string|fun()

---@alias LYRD.mappings.mapping LYRD.mappings.header_mapping|LYRD.mappings.standard_mapping

function L.plugins()
	setup.plugin({
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
				sort = { "alphanum" },
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

---Gets the command details
---@param mode string mode for the mapping
---@param command string|Command command to get the details
---@return LYRD.mappings.mapping_details
local function get_command(mode, command)
	local command_str = command
	local desc_str = nil
	local icon_str = nil
	if type(command) ~= "string" then
		command_str = command:as_vim_command(mode)
		desc_str = command.desc
		if type(command.icon) == "string" then
			icon_str = icons.icon(command.icon)
		else
			icon_str = command.icon
		end
	end
	return { command = command_str, desc = desc_str, icon = icon_str }
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
	local command_details = get_command(mode, command)
	table.insert(entry, 1, key_str)
	table.insert(entry, 2, command_details.command)
	entry.desc = documentation or command_details.desc
	entry.mode = mode
	entry.icon = command_details.icon
	wk.add({ entry })
end

---Creates a keybinding for a menu
---@param keys string
---@param title string|fun():string
---@param icon? string
---@param additional_modes? string[]
local function map_menu(keys, title, icon, additional_modes)
	local wk = require("which-key")
	local icon_str = nil
	if type(icon) == "string" then
		icon_str = icons.icon(icon)
	else
		icon_str = icon
	end
	local actual_title = nil
	if type(title) == "function" then
		actual_title = function()
			return "[" .. title() .. "]"
		end
	else
		actual_title = "[" .. title .. "]"
	end
	wk.add({ { keys, group = actual_title, icon = icon_str } })
	if additional_modes then
		for _, mode in ipairs(additional_modes) do
			wk.add({ { keys, group = actual_title, mode = mode, icon = icon_str } })
		end
	end
end

---Creates a set of keybindings
---@param mappings {[1]: string|string[], [2]:string, [3]:string|function|Command, [4]: table}[] contains the mapping definition as an array of (mode, key, command, options)
function L.keys(mappings, options)
	for _, mapping in ipairs(mappings) do
		local mode, key, command, opt = unpack(mapping)
		if opt == nil then
			opt = options
		end
		map_key(mode, nil, { key }, command, nil, opt)
	end
end

---Creates a set of keybindings
---@param filetypes string|string[] filetype or filetypes to create the mappings for
---@param prefix? string prefix for the mappings
---@param mappings {[1]: string|string[], [2]:string, [3]:string|function|Command, [4]: table}[] contains the mapping definition as an array of (mode, key, command, options)
function L.keys_per_filetype(filetypes, prefix, mappings, options)
	-- Create an autocommand group for the filetype
	local group = vim.api.nvim_create_augroup(filetypes .. "Mappings", { clear = true })
	-- Define the autocommand
	vim.api.nvim_create_autocmd("FileType", {
		pattern = filetypes,
		group = group,
		callback = function()
			for _, mapping in ipairs(mappings) do
				local mode, key, command, opt = unpack(mapping)
				if opt == nil then
					opt = options or {}
				end
				local command_details = get_command(mode, command)
				if not opt.desc then
					opt.desc = command_details.desc
				end
				local full_key = (prefix or "") .. key
				vim.api.nvim_buf_set_keymap(0, mode, full_key, command_details.command, opt)
			end
		end,
	})
end

---Creates a set of keybindings for a filetype or filetypes
---@param filetypes string|string[] filetype or filetypes to create the mappings for
---@param mappings {[1]: string|string[], [2]:string, [3]:string|function|Command, [4]: table}[] contains the mapping definition as an array of (mode, key, command, options)
function L.create_filetype_menu(filetypes, mappings, options)
	L.keys_per_filetype(filetypes, "<leader>" .. L.filetype_specific_leader_prefix, mappings, options)
end

--- Creates a menu
--- @param prefix string
--- @param items LYRD.mappings.mapping[]
function L.create_menu(prefix, items)
	local Hydra = require("hydra")
	for _, item in ipairs(items) do
		if item.type == "header" then
			map_menu(prefix .. item.key, item.title, item.icon, item.additional_modes)
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
			local color = "amaranth"
			if item.accept_foreign_keys then
				color = "pink"
			end
			Hydra({
				name = item.title,
				mode = "n",
				body = prefix .. item.key,
				hint = item.title,
				config = {
					color = color,
					invoke_on_body = true,
				},
				heads = heads,
			})
		else
			-- Map a menu item with its sequence of keys
			local key, command, additional_modes = unpack(item)
			map_key("n", nil, prefix .. key, command)
			if additional_modes then
				for _, mode in ipairs(additional_modes) do
					map_key(mode, nil, prefix .. key, command)
				end
			end
		end
	end
end

--- Creates a menu header
--- @param key string
--- @param title string|fun(): string
--- @param items LYRD.mappings.mapping[]
--- @param icon? string|fun()
--- @param additional_modes? string[]
--- @return LYRD.mappings.header_mapping
function L.menu_header(key, title, items, icon, additional_modes)
	---@type LYRD.mappings.header_mapping
	return {
		key = key,
		title = title,
		items = items,
		type = "header",
		icon = icon,
		additional_modes = additional_modes,
	}
end

--- Creates a submode header
--- @param key string
--- @param title string|fun(): string
--- @param items LYRD.mappings.mapping[]
--- @param accept_foreign_keys? boolean
--- @return LYRD.mappings.header_mapping
function L.submode_header(key, title, items, icon, accept_foreign_keys)
	---@type LYRD.mappings.header_mapping
	return {
		key = key,
		title = title,
		items = items,
		type = "submode",
		icon = icon,
		accept_foreign_keys = accept_foreign_keys,
	}
end

return L
