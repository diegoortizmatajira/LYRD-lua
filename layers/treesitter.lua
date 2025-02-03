local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Treesitter" }

function L.plugins()
	setup.plugin({
		{
			"nvim-treesitter/nvim-treesitter",
			opts = {},
			build = function()
				require("nvim-treesitter.install").update({ with_sync = true })()
			end,
		},
		{ -- Additional text objects via treesitter
			"nvim-treesitter/nvim-treesitter-textobjects",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
		},
		{
			"nvim-treesitter/playground",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			cmd = { "TSPlaygroundToggle" },
		},
		{
			"ThePrimeagen/refactoring.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
			},
			opt = {
				-- prompt for return type
				prompt_func_return_type = { go = true, cpp = true, c = true, java = true },
				-- prompt for function parameters
				prompt_func_param_type = { go = true, cpp = true, c = true, java = true },
			},
			config = function(_, opts)
				require("refactoring").setup(opts)
				require("telescope").load_extension("refactoring")
			end,
		},
	})
end

function L.settings()
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"c",
			"c_sharp",
			"cpp",
			"css",
			"csv",
			"go",
			"json",
			"lua",
			"python",
			"query",
			"rust",
			"typescript",
			"vue",
			"http",
			"yaml",
			"gomod",
			"gosum",
			"gotmpl",
			"regex",
		},
		highlight = {
			enable = true,
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		indent = {
			enable = true,
			disable = { "python" },
		},
		playground = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>a"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>A"] = "@parameter.inner",
				},
			},
		},
	})
	commands.implement("*", {
		{ cmd.LYRDCodeRefactor, require("refactoring").select_refactor },
		{ cmd.LYRDViewTreeSitterPlayground, ":TSPlaygroundToggle" },
	})
end

return L
