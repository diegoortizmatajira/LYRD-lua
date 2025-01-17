local setup = require("LYRD.setup")

local L = { name = "Markdown" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"MeanderingProgrammer/markdown.nvim",
			main = "render-markdown",
			ft = { "markdown" },
			opts = {
				heading = {
					sign = false,
					icons = { " ", " ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
					width = "block",
				},
				code = {
					sign = false,
					width = "block", -- use 'language' if colorcolumn is important for you.
					right_pad = 1,
				},
				dash = {
					width = 79,
				},
				pipe_table = {
					style = "full", -- use 'normal' if colorcolumn is important for you.
				},
			},
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			}, -- if you prefer nvim-web-devicons
		},
		{
			"SCJangra/table-nvim",
			ft = "markdown",
			opts = {
				padd_column_separators = true, -- Insert a space around column separators.
				mappings = { -- next and prev work in Normal and Insert mode. All other mappings work in Normal mode.
					next = "<TAB>", -- Go to next cell.
					prev = "<S-TAB>", -- Go to previous cell.
					insert_row_up = "<A-k>", -- Insert a row above the current row.
					insert_row_down = "<A-j>", -- Insert a row below the current row.
					move_row_up = "<A-S-k>", -- Move the current row up.
					move_row_down = "<A-S-j>", -- Move the current row down.
					insert_column_left = "<A-h>", -- Insert a column to the left of current column.
					insert_column_right = "<A-l>", -- Insert a column to the right of current column.
					move_column_left = "<A-S-h>", -- Move the current column to the left.
					move_column_right = "<A-S-l>", -- Move the current column to the right.
					insert_table = "<A-t>", -- Insert a new table.
					insert_table_alt = "<A-S-t>", -- Insert a new table that is not surrounded by pipes.
					delete_column = "<A-d>", -- Delete the column under cursor.
				},
			},
		},
	})
end

function L.preparation(_)
	-- Registers code actions in NULL LS
	local lsp = require("LYRD.layers.lsp")
	lsp.register_code_actions({ "markdown" }, function(_)
		local result = {}
		-- Checks if the cursor is in a table
		local node = vim.treesitter.get_node()
		local is_table = node ~= nil and node:type():match("^pipe_table")
		local edit = require("table-nvim.edit")
		if is_table then
			local table_actions = {
				{ title = "Insert row up", action = edit.insert_row_up },
				{ title = "Insert row down", action = edit.insert_row_down },
				{ title = "Insert column left", action = edit.insert_column_left },
				{ title = "Insert column right", action = edit.insert_column_right },
				{ title = "Move row up", action = edit.move_row_up },
				{ title = "Move row down", action = edit.move_row_down },
				{ title = "Move column left", action = edit.move_column_left },
				{ title = "Move column right", action = edit.move_column_right },
				{ title = "Delete current column", action = edit.delete_current_column },
			}
			for _, value in ipairs(table_actions) do
				table.insert(result, value)
			end
		else
			table.insert(result, { title = "Insert table", action = edit.insert_table })
		end

		return result
	end)
end

return L
