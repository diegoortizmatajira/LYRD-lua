local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Test", test_adapters = {} }

function L.plugins(s)
	setup.plugin(s, {
		"nvim-neotest/nvim-nio",
		{
			"nvim-neotest/neotest",
			dependencies = {
				"nvim-neotest/nvim-nio",
				"nvim-lua/plenary.nvim",
				"antoinemadec/FixCursorHold.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
			event = "VeryLazy",
			opts = function()
				print("Loading test adapters", #L.test_adapters)
				return { adapters = L.test_adapters }
			end,
		},
	})
end

function L.configure_adapter(adapter)
	table.insert(L.test_adapters, adapter)
end

function L.settings(s)
	commands.implement(s, "neotest-summary", {
		{ cmd.LYRDBufferSave, [[:echo 'No saving']] },
	})
	commands.implement(s, "*", {
		{
			cmd.LYRDTest,
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
		},
		{
			cmd.LYRDTestSuite,
			function()
				require("neotest").run.run(vim.fn.getcwd())
			end,
		},
		{
			cmd.LYRDTestFile,
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
		},
		{
			cmd.LYRDTestFunc,
			function()
				require("neotest").run.run()
			end,
		},
		{
			cmd.LYRDTestLast,
			function()
				require("neotest").run.run()
			end,
		},
		{
			cmd.LYRDTestSummary,
			function()
				require("neotest").summary.toggle()
			end,
		},
	})
end

function L.complete(_) end

return L
