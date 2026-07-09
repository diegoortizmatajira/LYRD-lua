local commands = require("LYRD.layers.commands")
local setup = require("LYRD.shared.setup")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.Test: LYRD.shared.setup.Module
local L = {
	name = "Test Runner",
	unskippable = true,
	test_adapters = {},
}

function L.plugins()
	setup.plugin({
		{ "nvim-neotest/nvim-nio" },
		{
			"nvim-neotest/neotest",
			priority = 0,
			setup = false, -- It will be setup manually later
			dependencies = {
				"nvim-neotest/nvim-nio",
				"nvim-lua/plenary.nvim",
				"antoinemadec/fixcursorhold.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
		},
		{
			"andythigpen/nvim-coverage",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {},
		},
	})
end

function L.configure_adapter(adapter)
	table.insert(L.test_adapters, adapter)
end

function L.settings()
	-- Called only when all adapters have been collected into L.test_adapters
	local neotest = require("neotest")
	--- @diagnostic disable-next-line: missing-fields
	neotest.setup({
		adapters = L.test_adapters,
		output = {
			enabled = true, -- Enable output
			open_on_run = true, -- Automatically open the output window
		},
		consumers = {
			--- uses overseer to run tests
			--- @diagnostic disable-next-line: assign-type-mismatch
			overseer = require("neotest.consumers.overseer"),
		},
	})
	commands.implement("*", {
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
			cmd.LYRDTestDebugFunc,
			function()
				require("neotest").run.run({ strategy = "dap" })
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
		{ cmd.LYRDTestOutput, ":Neotest output-panel" },
		{ cmd.LYRDTestCoverageSummary, ":CoverageSummary" },
		{ cmd.LYRDTestCoverage, ":CoverageToggle" },
	})
end

function L.complete()
	-- No completion needed for this layer
end

return L
