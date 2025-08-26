local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

---@class LYRD.ui.special_type
---@field type_id string
---@field title? string
---@field keep_window? boolean
---@field keep_tab? boolean
---@field allow_saving? boolean
---@field allow_replacement? boolean
---@field prevent_closing? boolean
---
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
		{ type_id = "alpha", prevent_closing = true },
		{ type_id = "code-stdout", title = "Playground output" },
		{ type_id = "copilot-chat", title = "AI Chat" },
		{ type_id = "dbout" },
		{ type_id = "dbui", title = "Database" },
		{ type_id = "fugitive" },
		{ type_id = "gitcommit" },
		{ type_id = "help" },
		{ type_id = "http_response" },
		{ type_id = "lazy" },
		{ type_id = "lazy" },
		{ type_id = "neotest-summary", title = "Tests" },
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

-- Gets the list of buffers that will have a title in their sidebar
local function get_buffer_offsets()
	local result = {}
	for _, value in pairs(L.special_filetypes) do
		if value.title then
			table.insert(result, {
				filetype = value.type_id,
				text = value.title,
				highlight = "PanelHeading",
				padding = 1,
			})
		end
	end
	return result
end

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

--- Closes the current buffer while checking for specific conditions.
--- If the buffer matches a predefined special filename, filetype, or buffertype
--- and has the `prevent_closing` attribute set to true, it will not be closed.
--- Otherwise, it uses the "mini.bufremove" plugin to delete the buffer.
local function close_buffer()
	local conditions = check_closing_conditions()
	if conditions and conditions.prevent_closing then
		vim.notify("This buffer cannot be closed", vim.log.levels.WARN)
		return
	end
	require("mini.bufremove").delete(0, false)
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

function L.complete() end

return L
