local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")
local c = require("LYRD.layers.commands").command_shortcut

local L = { name = "Mappings" }

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
				-- ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
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
			"pogyomo/submode.nvim",
			lazy = true,
		},
	})
end

---Creates a keybinding
---@param mode string
---@param lead string
---@param keys string|table
---@param command string|table
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
		command_str = c(command.name)
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

local function map_menu(keys, title)
	local wk = require("which-key")
	wk.add({ { keys, group = "[" .. title .. "]" } })
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

function L.create_menu(prefix, items)
	for _, item in ipairs(items) do
		if #item == 4 and item[4] == "header" then
			-- Map a menu header and its child items
			local key, title, sub_items, _ = unpack(item)
			map_menu(prefix .. key, title)
			L.create_menu(prefix .. key, sub_items)
		elseif #item == 4 and item[4] == "submode" then
			-- Creates a submode
			local key, title, sub_items, _ = unpack(item)
			map_menu(prefix .. key, title)
			local submode = require("submode")
			submode.create("submode_" .. prefix .. key, {
				mode = "n",
				enter = prefix .. key,
				leave = { "q", "<ESC>" },
				default = function(register)
					for _, mode_item in ipairs(sub_items) do
						local submode_key, command = unpack(mode_item)
						if type(command) == "string" then
							register(submode_key, command)
						else
							register(submode_key, c(command.name))
						end
					end
				end,
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

function L.menu_header(key, title, items)
	return { key, title, items, "header" }
end

function L.submode_header(key, title, items)
	return { key, title, items, "submode" }
end

return L
