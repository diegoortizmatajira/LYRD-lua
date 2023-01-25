local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "Test" }

function L.plugins(s)
	setup.plugin(s, {
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
		LYRDBufferSave = [[:echo 'No saving']],
	})
	commands.implement(s, "*", {
		LYRDTest = function()
			neotest.run.run(vim.fn.expand("%"))
		end,
		LYRDTestSuite = function()
			neotest.run.run(vim.fn.getcwd())
		end,
		LYRDTestFile = function()
			neotest.run.run(vim.fn.expand("%"))
		end,
		LYRDTestFunc = neotest.run.run,
		LYRDTestLast = neotest.run.run,
		LYRDTestSummary = neotest.summary.toggle,
	})
end

return L
