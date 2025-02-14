local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local handler = commands.handler
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "REPL",
	-- Add as many filetypes as you have iron.nvim configured to support REPL
	supported_filetypes = { "python" },
	selected_repl_provider = "iron",
}

local repl_providers = {
	iron = {
		plugins = {
			{
				-- Enables REPL processing
				"vigemus/iron.nvim",
				config = function()
					local iron = require("iron")
					local common = require("iron.fts.common")
					iron.setup({
						repl_open_cmd = "horizontal bot 20 split",
						repl_definition = {
							python = {
								command = function()
									-- Tries to check if IPython, Python or Python3 are available in that specific order.
									local ipython_available = vim.fn.executable("ipython") == 1
									local python_available = vim.fn.executable("python") == 1
									local binary = (ipython_available and { "ipython", "--no-autoindent" })
										or (python_available and { "python" })
										or { "python3" }
									return binary
								end,
								format = common.bracketed_paste_python,
							},
						},
					})
				end,
				main = "iron.core",
				ft = L.supported_filetypes,
			},
		},
	},
	molten = {
		plugins = {
			{
				"vhyrro/luarocks.nvim",
				priority = 1001, -- this plugin needs to run before anything else
				opts = {
					rocks = { "magick" },
				},
			},
			{
				"3rd/image.nvim",
				dependencies = { "luarocks.nvim" },
				opts = {},
				lazy = true,
			},
			{
				"benlubas/molten-nvim",
				dependencies = {
					"3rd/image.nvim",
				},
				build = ":UpdateRemotePlugins",
				init = function()
					-- these are examples, not defaults. Please see the readme
					vim.g.molten_image_provider = "image.nvim"
					-- Output Windowquarto.runner
					vim.g.molten_auto_open_output = false
					vim.g.molten_output_win_max_height = 30

					-- Virtual Text
					vim.g.molten_virt_text_output = true
					-- vim.g.molten_cover_empty_lines = true
					-- vim.g.molten_comment_string = "# %%"

					vim.g.molten_virt_text_output = true
					vim.g.molten_use_border_highlights = true
					vim.g.molten_virt_lines_off_by_1 = true
					vim.g.molten_wrap_output = true
					vim.g.molten_tick_rate = 142
				end,
				ft = L.supported_filetypes,
				cmd = { "MoltenInit" },
			},
		},
	},
}

local function empty_jupyter_notebook()
	return [[{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "initial_id",
   "metadata": {
    "collapsed": true
   },
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 2
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython2",
   "version": "2.7.6"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}]]
end

function L.plugins()
	setup.plugin(repl_providers[L.selected_repl_provider].plugins)
	setup.plugin({
		{
			-- Enables notebook like mode
			"GCBallesteros/NotebookNavigator.nvim",
			dependencies = {
				"echasnovski/mini.comment",
			},
			ft = L.supported_filetypes,
			opts = {
				repl_provider = L.selected_repl_provider,
			},
		},
		{
			"diegoortizmatajira/jupytext.nvim",
			-- "GCBallesteros/jupytext.nvim",
			opts = {
				empty_notebook_generator = empty_jupyter_notebook,
			},
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

function L.settings()
	commands.implement(L.supported_filetypes, {
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
