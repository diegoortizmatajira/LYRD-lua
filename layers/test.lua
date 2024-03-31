local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Test" }

function L.plugins(s)
	setup.plugin(s, {
		"nvim-neotest/nvim-nio",
		{
			"nvim-neotest/neotest",
			requires = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "antoinemadec/FixCursorHold.nvim" },
		},
		"nvim-neotest/neotest-go",
	})
end

function L.settings(s)
	local neotest = require("neotest")
	neotest.setup({ adapters = { require("neotest-go") } })
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
		{ cmd.LYRDTestFunc, neotest.run.run },
		{ cmd.LYRDTestLast, neotest.run.run },
		{ cmd.LYRDTestSummary, neotest.summary.toggle },
	})
end

return L
