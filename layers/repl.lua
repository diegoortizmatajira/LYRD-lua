local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local handler = commands.handler
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "REPL" }

function L.plugins(s)
	setup.plugin(s, {
		{
			-- Enables REPL processing
			"vigemus/iron.nvim",
			opts = {
				keymaps = {
					send_line = "<leader>u",
					visual_send = "<leader>u",
				},
				config = {
					repl_open_cmd = "horizontal bot 20 split",
					repl_definition = {
						python = {
							command = function()
								-- Tries to check if IPython, Python or Python3 are available in that specific order.
								local ipythonAvailable = vim.fn.executable("ipython") == 1
								local pythonAvailable = vim.fn.executable("python") == 1
								local binary = (ipythonAvailable and "ipython")
									or (pythonAvailable and "python")
									or "python3"
								return { binary }
							end,
						},
					},
				},
			},
			main = "iron.core",
		},
		{
			-- Enables notebook like mode
			"GCBallesteros/NotebookNavigator.nvim",
			keys = {
				{
					"]h",
					function()
						require("notebook-navigator").move_cell("d")
					end,
				},
				{
					"[h",
					function()
						require("notebook-navigator").move_cell("u")
					end,
				},
				{ "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
				{ "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
			},
			dependencies = {
				"echasnovski/mini.comment",
				"vigemus/iron.nvim", -- repl provider
				"anuvyklack/hydra.nvim",
			},
			event = "VeryLazy",
			config = function()
				local nn = require("notebook-navigator")
				nn.setup({ activate_hydra_keys = "<leader>h" })
			end,
		},
		{
			"echasnovski/mini.hipatterns",
			event = "VeryLazy",
			dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
			opts = function()
				local nn = require("notebook-navigator")
				local opts = { highlighters = { cells = nn.minihipatterns_spec } }
				return opts
			end,
		},
	})
end

function L.preparation(s) end

function L.settings(s)
	local nn = require("notebook-navigator")
	commands.implement(s, "*", {
		{ cmd.LYRDReplView, ":IronRepl" },
		{ cmd.LYRDReplRestart, ":IronRestart" },
		{ cmd.LYRDReplNotebookRunCell, nn.run_cell },
		{ cmd.LYRDReplNotebookRunCellAndMove, nn.run_and_move },
		{ cmd.LYRDReplNotebookRunAllCells, nn.run_all_cells },
		-- { cmd.LYRDReplNotebookRunAllAbove, nn.run },
		{ cmd.LYRDReplNotebookRunAllBelow, nn.run_cells_below },
		{ cmd.LYRDReplNotebookMoveCellUp, handler(nn.move_cell, "u") },
		{ cmd.LYRDReplNotebookMoveCellDown, handler(nn.move_cell, "d") },
		{ cmd.LYRDReplNotebookAddCellAbove, nn.add_cell_above },
		{ cmd.LYRDReplNotebookAddCellBelow, nn.add_cell_below },
	})
end

function L.keybindings(s) end

function L.complete(s) end

return L
