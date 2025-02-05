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
		{ type_id = "alpha" },
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

-- Gets the list of buffers that will be closed when the buffer is closed
local function get_buffers_that_close_with_their_window()
	local result = {}
	for _, value in pairs(L.special_filenames) do
		if not value.keep_window then
			table.insert(result, { filename = value.type_id })
		end
	end
	for _, value in pairs(L.special_filetypes) do
		if not value.keep_window then
			table.insert(result, { filetype = value.type_id })
		end
	end
	for _, value in pairs(L.special_buffertypes) do
		if not value.keep_window then
			table.insert(result, { buftype = value.type_id })
		end
	end
end

function L.plugins()
	setup.plugin({
		{
			"diegoortizmatajira/bufdelete.nvim",
			opts = {
				debug = false,
				close_with_their_window = get_buffers_that_close_with_their_window(),
			},
		},
		{
			"fasterius/simple-zoom.nvim",
			opts = {
				hide_tabline = false,
			},
		},
		{
			"akinsho/bufferline.nvim",
			-- version = "*",
			opts = {
				highlights = {
					background = {
						italic = true,
					},
					buffer_selected = {
						bold = true,
						italic = false,
					},
				},
				options = {
					mode = "buffers",
					numbers = "none",
					show_buffer_close_icons = false,
					offsets = get_buffer_offsets(),
				},
			},
			dependencies = "nvim-tree/nvim-web-devicons",
		},
	})
end

function L.preparation() end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDBufferClose, ":Bdelete" },
		{ cmd.LYRDBufferCloseAll, ":bufdo Bdelete" },
		{ cmd.LYRDBufferForceClose, ":Bdelete!" },
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

	-- Causes alpha to be opened when closing all buffers
	vim.api.nvim_create_augroup("alpha_on_empty", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		pattern = "BDeletePost *",
		group = "alpha_on_empty",
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local name = vim.api.nvim_buf_get_name(bufnr)

			if vim.bo[bufnr].filetype ~= "alpha" and name == "" then
				vim.cmd([[:Alpha | bd#]])
			end
		end,
	})
end

function L.keybindings() end

function L.complete() end

return L
