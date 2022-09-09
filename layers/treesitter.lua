local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "Treesitter" }

function L.plugins(s)
	setup.plugin(s, {
		{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
		"nvim-treesitter/playground",
		{
			"ThePrimeagen/refactoring.nvim",
			event = "VimEnter",
			config = function()
				require("config.refactoring").setup()
			end,
			requires = { { "nvim-lua/plenary.nvim" }, { "nvim-treesitter/nvim-treesitter" } },
		},
	})
end

function L.settings(s)
	require("nvim-treesitter.configs").setup({
		highlight = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		indent = { enable = true },
	})
	require("refactoring").setup({
		-- prompt for return type
		prompt_func_return_type = { go = true, cpp = true, c = true, java = true },
		-- prompt for function parameters
		prompt_func_param_type = { go = true, cpp = true, c = true, java = true },
	})
	require("telescope").load_extension("refactoring")
	commands.implement(s, "*", { LYRDCodeRefactor = ":lua require('refactoring').select_refactor()" })
end

return L
