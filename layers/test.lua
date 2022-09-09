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
	require("neotest").setup({ adapters = { require("neotest-go") } })
	commands.implement(s, "*", {
		LYRDTest = [[:lua require('neotest').run.run(vim.fn.expand('%'))]],
		LYRDTestSuite = [[:lua require('neotest').run.run(vim.fn.getcwd())]],
		LYRDTestFile = [[:lua require('neotest').run.run(vim.fn.expand('%'))]],
		LYRDTestFunc = [[:lua require("neotest").run.run()]],
		LYRDTestLast = [[:lua require('neotest').run.run()]],
		LYRDTestSummary = [[:lua require('neotest').summary.toggle()]],
	})
end

function L.keybindings(_) end

function L.complete(_) end

return L
