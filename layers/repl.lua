local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local handler = commands.handler
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "REPL",
	-- Add as many filetypes as you have iron.nvim configured to support REPL
	supported_filetypes = { "python" },
}

function L.plugins(s)
	setup.plugin(s, {
		{
			-- Enables REPL processing
			"vigemus/iron.nvim",
			opts = {
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
			ft = L.supported_filetypes,
		},
		{
			-- Enables notebook like mode
			"GCBallesteros/NotebookNavigator.nvim",
			dependencies = {
				"echasnovski/mini.comment",
				"vigemus/iron.nvim", -- repl provider
			},
			ft = L.supported_filetypes,
			opts = {},
		},
		{
			"echasnovski/mini.hipatterns",
			dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
			opts = function()
				local nn = require("notebook-navigator")
				local opts = { highlighters = { cells = nn.minihipatterns_spec } }
				return opts
			end,
			ft = L.supported_filetypes,
		},
	})
end

function L.settings(s)
	commands.implement(s, L.supported_filetypes, {
		{ cmd.LYRDReplView, ":IronRepl" },
		{ cmd.LYRDReplRestart, ":IronRestart" },
		{
			cmd.LYRDReplNotebookRunCell,
			function()
				local nn = require("notebook-navigator")
				nn.run_cell()
			end,
		},
		{
			cmd.LYRDReplNotebookRunCellAndMove,
			function()
				local nn = require("notebook-navigator")
				nn.run_and_move()
			end,
		},
		{
			cmd.LYRDReplNotebookRunAllCells,
			function()
				local nn = require("notebook-navigator")
				nn.run_all_cells()
			end,
		},
		-- { cmd.LYRDReplNotebookRunAllAbove, nn.run },
		{
			cmd.LYRDReplNotebookRunAllBelow,
			function()
				local nn = require("notebook-navigator")
				nn.run_cells_below()
			end,
		},
		{
			cmd.LYRDReplNotebookMoveCellUp,
			function()
				local nn = require("notebook-navigator")
				nn.move_cell("u")
			end,
		},
		{
			cmd.LYRDReplNotebookMoveCellDown,
			function()
				local nn = require("notebook-navigator")
				nn.move_cell("d")
			end,
		},
		{
			cmd.LYRDReplNotebookAddCellAbove,
			function()
				local nn = require("notebook-navigator")
				nn.add_cell_above()
			end,
		},
		{
			cmd.LYRDReplNotebookAddCellBelow,
			function()
				local nn = require("notebook-navigator")
				nn.add_cell_below()
			end,
		},
	})
end

return L
