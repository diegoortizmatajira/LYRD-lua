local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.ui.special_type
---@field type_id string
---@field title? string
---@field allow_saving? boolean
---@field prevent_closing? boolean
---@field map_q? boolean

---@class LYRD.layer.Buffers: LYRD.setup.Module
local L = {
	name = "Buffers",

	---@type LYRD.ui.special_type[]
	special_filenames = {

		{ type_id = "fugitive:" },
		{ type_id = "diffview:" },
		{ type_id = "kulala:" },
	},
	---@type LYRD.ui.special_type[]
	special_filetypes = {
		-- You can add entries here to mark special filetypes that have a header in their
		-- sidebar or that should close with their window (unless the value true is provided)
		{ type_id = "DiffviewFileHistory" },
		{ type_id = "DiffviewFiles", title = "Diff View" },
		{ type_id = "NeogitPopup" },
		{ type_id = "NeogitStatus" },
		{ type_id = "NvimTree", title = "Explorer" },
		{ type_id = "OverseerList" },
		{ type_id = "aerial", title = "Outline" },
		{ type_id = "code-stdout", title = "Playground output" },
		{ type_id = "copilot-chat", title = "AI Chat" },
		{ type_id = "db-cli-output.csv" },
		{ type_id = "db-cli-output.text" },
		{ type_id = "db-cli-sidebar" },
		{ type_id = "dbout" },
		{ type_id = "dbui", title = "Database" },
		{ type_id = "fugitive" },
		{ type_id = "gitcommit" },
		{ type_id = "grug-far", map_q = true },
		{ type_id = "help", map_q = true },
		{ type_id = "http_response" },
		{ type_id = "lazy" },
		{ type_id = "lazyterm" },
		{ type_id = "neotest-attach", map_q = true },
		{ type_id = "neotest-output", map_q = true },
		{ type_id = "neotest-summary", map_q = true, title = "Tests" },
		{ type_id = "noice" },
		{ type_id = "qf" },
		{ type_id = "toggleterm" },
		{ type_id = "trouble" },
		{ type_id = "tsplayground", title = "Treesitter Playground" },
	},
	---@type LYRD.ui.special_type[]
	special_buffertypes = {
		{ type_id = "terminal" },
	},
}

local function check_closing_conditions()
	local buffer_number = vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(buffer_number)
	local file_type = vim.bo[buffer_number].filetype
	local buf_type = vim.bo[buffer_number].buftype
	for _, value in pairs(L.special_filenames) do
		if filename:sub(1, #value.type_id) == value.type_id then
			return value
		end
	end
	for _, value in pairs(L.special_filetypes) do
		if file_type == value.type_id then
			return value
		end
	end
	for _, value in pairs(L.special_buffertypes) do
		if buf_type == value.type_id then
			return value
		end
	end
	return nil
end

local open_starter_if_empty_buffer = function()
	local buf_id = vim.api.nvim_get_current_buf()
	local is_empty = vim.api.nvim_buf_get_name(buf_id) == "" and vim.bo[buf_id].filetype == ""
	if not is_empty then
		return
	end
	cmd.LYRDViewHomePage:execute()
end

--- Closes the current buffer while checking for any special conditions.
---
--- If the buffer is marked as `prevent_closing` in the `special_filenames`,
--- `special_filetypes`, or `special_buffertypes` lists, the buffer will not
--- be closed, and a warning will be displayed.
---
--- If the closed buffer is the last listed buffer, it will open the home page.
---
--- Requirements:
--- - Relies on the `mini.bufremove` plugin for buffer deletion.
--- - Executes `LYRDViewHomePage` command when no more buffers are visible.
local function close_buffer()
	local conditions = check_closing_conditions()
	if conditions then
		if conditions.prevent_closing then
			vim.notify("This buffer cannot be closed", vim.log.levels.WARN)
			return
		end
		-- If the buffer is special, we just close the window unlless it is the last one
		-- (meaning no other buffer is visible)
		local wins = vim.api.nvim_list_wins()
		if #wins > 1 then
			vim.cmd("close")
			return
		end
	end
	-- If it's a normal buffer, we close it properly
	local closed = require("mini.bufremove").delete(0, false)
	if closed then
		open_starter_if_empty_buffer()
	end
end

--- Moves to the previous buffer while checking for any special conditions.
---
--- If the current buffer matches conditions specified in the `special_filenames`,
--- `special_filetypes`, or `special_buffertypes` lists, the operation to move
--- to the previous buffer will be skipped.
---
--- This function ensures that special buffers remain unaffected by navigation.
local function buffer_prev()
	local conditions = check_closing_conditions()
	if conditions then
		return
	end
	vim.cmd("bprevious")
end

--- Moves to the next buffer while checking for any special conditions.
---
--- If the current buffer matches conditions specified in the `special_filenames`,
--- `special_filetypes`, or `special_buffertypes` lists, the operation to move
--- to the next buffer will be skipped.
---
--- This function ensures that special buffers remain unaffected by navigation.
local function buffer_next()
	local conditions = check_closing_conditions()
	if conditions then
		return
	end
	vim.cmd("bnext")
end

function L.plugins()
	setup.plugin({
		{
			"fasterius/simple-zoom.nvim",
			opts = {
				hide_tabline = false,
			},
		},
		{
			"echasnovski/mini.bufremove",
			version = "*",
		},
	})
end

function L.preparation() end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDBufferClose, close_buffer },
		{ cmd.LYRDBufferNext, buffer_next },
		{ cmd.LYRDBufferPrev, buffer_prev },
		{ cmd.LYRDBufferCloseAll, ":bufdo " .. cmd.LYRDBufferClose.name },
		{ cmd.LYRDBufferForceClose, ":" .. cmd.LYRDBufferClose.name .. "!" },
		{ cmd.LYRDWindowZoom, ":SimpleZoomToggle" },
	})
	-- Disable saving for special filetypes
	for _, value in pairs(L.special_filetypes) do
		if not value.allow_saving then
			commands.implement(value.type_id, {
				{
					cmd.LYRDBufferSave,
					function()
						vim.notify("No saving", vim.log.levels.WARN)
					end,
				},
			})
		end
	end
end

function L.keybindings() end

function L.map_q_for_closing_ft(ft)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = function()
			vim.keymap.set("n", "q", cmd.LYRDBufferClose:shortcut(), {
				buffer = true,
				desc = "Close",
				silent = true,
			})
		end,
	})
end
function L.complete()
	for _, item in pairs(L.special_filetypes) do
		if item.map_q then
			L.map_q_for_closing_ft(item.type_id)
		end
	end
end

return L
