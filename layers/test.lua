local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Test", test_adapters = {} }

function L.plugins(s)
	setup.plugin(s, {
		{ "nvim-neotest/nvim-nio" },
		{
			"nvim-neotest/neotest",
			priority = 0,
			config = false, -- It will be called by hand
			dependencies = {
				"nvim-neotest/nvim-nio",
				"nvim-lua/plenary.nvim",
				"antoinemadec/fixcursorhold.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
		},
	})
end

function L.configure_adapter(adapter)
	table.insert(L.test_adapters, adapter)
end

function L.settings(s)
	-- Called only when all adapters have been collected into L.test_adapters
	require("neotest").setup({ adapters = L.test_adapters })

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

return L
