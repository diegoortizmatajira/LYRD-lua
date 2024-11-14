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

	-- Creates an autocommand to enable q to close test panels
	local group = vim.api.nvim_create_augroup("NeotestConfig", {})
	for _, ft in ipairs({ "output", "attach", "summary" }) do
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "neotest-" .. ft,
			group = group,
			callback = function(opts)
				vim.keymap.set("n", "q", function()
					pcall(vim.api.nvim_win_close, 0, true)
				end, {
					buffer = opts.buf,
				})
			end,
		})
	end
end

return L
