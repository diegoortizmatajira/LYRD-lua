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

local function get_listed_buffers()
	local listed_buffers = {}
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[bufnr].buflisted then
			table.insert(listed_buffers, bufnr)
		end
	end
	return listed_buffers
end

--- Closes the buffer without removing the window
local function close_buffer(options)
	local function finalize(final_command, param)
		if final_command then
			local command_str = final_command
			if options and options.bang then
				command_str = command_str .. "!"
			end
			if param then
				command_str = command_str .. " " .. param
			end
			vim.cmd(command_str)
		end
		local bufnr = vim.api.nvim_get_current_buf()
		local name = vim.api.nvim_buf_get_name(bufnr)

		if vim.bo[bufnr].filetype ~= "alpha" and name == "" then
			vim.cmd([[:Alpha | bd#]])
		end
	end
	local conditions = check_closing_conditions()
	-- If the buffer is a special buffer, close it
	if conditions then
		if conditions.prevent_closing then
			finalize()
			return
		end
		if not conditions.keep_tab then
			-- If there are more than one tab, close the current tab
			local tabs = vim.api.nvim_list_tabpages()
			if #tabs > 1 then
				finalize("tabclose")
				return
			end
		end
		if not conditions.keep_window then
			-- If there are more than one window, close the current window
			local windows = vim.api.nvim_tabpage_list_wins(0)
			if #windows > 1 then
				finalize("close")
				return
			end
		end
	end
	-- Gets the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()
	-- Selects the next buffer to prevent the window from getting closed
	vim.cmd("bnext")
	local alternate_bufnr = vim.api.nvim_get_current_buf()
	-- If there is no alternate buffer, create a new empty buffer to prevent the window from getting closed
	if alternate_bufnr == bufnr then
		vim.cmd("enew")
		-- alternate_bufnr = vim.api.nvim_get_current_buf()
	end
	-- If the buffer to be closed is in multiple windows, set the alternate buffer
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf_number = vim.api.nvim_win_get_buf(win)
		if buf_number == bufnr then
			vim.api.nvim_win_set_buf(win, alternate_bufnr)
		end
	end
	finalize("bdelete", bufnr)
end

function L.plugins()
	setup.plugin({
		{
			"fasterius/simple-zoom.nvim",
			opts = {
				hide_tabline = false,
			},
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
