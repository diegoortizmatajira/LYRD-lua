local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Test", test_adapters = {} }

function L.plugins(s)
	setup.plugin(s, {
		"nvim-neotest/nvim-nio",
		{
			"nvim-neotest/neotest",
			requires = {
				"nvim-neotest/nvim-nio",
				"nvim-lua/plenary.nvim",
				"antoinemadec/FixCursorHold.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
		},
	})
end

function L.configure_adapter(adapter)
	table.insert(L.test_adapters, adapter)
end

function L.settings(s)
	local neotest = require("neotest")
	commands.implement(s, "neotest-summary", {
		{ cmd.LYRDBufferSave, [[:echo 'No saving']] },
	})
	commands.implement(s, "*", {
		{
			cmd.LYRDTest,
			function()
				neotest.run.run(vim.fn.expand("%"))
			end,
		},
		{
			cmd.LYRDTestSuite,
			function()
				neotest.run.run(vim.fn.getcwd())
			end,
		},
		{
			cmd.LYRDTestFile,
			function()
				neotest.run.run(vim.fn.expand("%"))
			end,
		},
		{
			cmd.LYRDTestFunc,
			function()
				neotest.run.run()
			end,
		},
		{
			cmd.LYRDTestLast,
			function()
				neotest.run.run()
			end,
		},
		{
			cmd.LYRDTestSummary,
			function()
				neotest.summary.toggle()
			end,
		},
	})
end

function L.complete(_)
	local neotest = require("neotest")
	neotest.setup({ adapters = L.test_adapters })
end

return L
