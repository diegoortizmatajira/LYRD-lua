local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local handler = commands.handler
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "REPL",
	-- Add as many filetypes as you have iron.nvim configured to support REPL
	supported_filetypes = { "python" },
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
	setup.plugin({
		-- {
		-- 	"vhyrro/luarocks.nvim",
		-- 	priority = 1001, -- this plugin needs to run before anything else
		-- 	opts = {
		-- 		rocks = { "magick" },
		-- 	},
		-- },
		-- {
		-- 	"3rd/image.nvim",
		-- 	dependencies = { "luarocks.nvim" },
		-- 	opts = {},
		-- },
		-- {
		-- 	"benlubas/molten-nvim",
		-- 	version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		-- 	build = ":UpdateRemotePlugins",
		--
		-- 	init = function()
		-- 		-- this is an example, not a default. Please see the readme for more configuration options
		-- 		vim.g.molten_image_provider = "image.nvim"
		-- 		vim.g.molten_output_win_max_height = 20
		-- 	end,
		-- },
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
								local binary = (
									ipython_available
									and {
										"ipython",
										"--no-autoindent",
										"--ZMQTerminalInteractiveShell.image_handler=None",
									}
								)
									or (python_available and { "python" })
									or { "python3" }
								vim.notify("Using " .. binary[1] .. " as the Python REPL")
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
		{
			-- Enables notebook like mode
			"GCBallesteros/NotebookNavigator.nvim",
			dependencies = {
				"echasnovski/mini.comment",
				"vigemus/iron.nvim", -- repl provider
				-- "benlubas/molten-nvim", -- alternative repl provider
			},
			ft = L.supported_filetypes,
			opts = {},
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
