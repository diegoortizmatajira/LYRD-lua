local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "Treesitter" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"nvim-treesitter/nvim-treesitter",
			run = function()
				pcall(require("nvim-treesitter.install").update({ with_sync = true }))
			end,
		},
		{ -- Additional text objects via treesitter
			"nvim-treesitter/nvim-treesitter-textobjects",
			after = "nvim-treesitter",
		},
		{
			"nvim-treesitter/playground",
			after = "nvim-treesitter",
		},
		{
			"ThePrimeagen/refactoring.nvim",
			event = "VimEnter",
			config = function()
				require("config.refactoring").setup()
			end,
			requires = {
				{ "nvim-lua/plenary.nvim" },
				{ "nvim-treesitter/nvim-treesitter" },
			},
		},
	})
end

function L.settings(s)
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "query", "c", "cpp", "go", "lua", "python", "rust", "typescript", "help" },
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
	require("refactoring").setup({
		-- prompt for return type
		prompt_func_return_type = { go = true, cpp = true, c = true, java = true },
		-- prompt for function parameters
		prompt_func_param_type = { go = true, cpp = true, c = true, java = true },
	})
	require("telescope").load_extension("refactoring")
	commands.implement(s, "tsplayground", {
		LYRDBufferSave = [[:echo 'No saving']],
	})
	commands.implement(s, "query", {
		LYRDBufferSave = [[:echo 'No saving']],
	})
	commands.implement(s, "*", { LYRDCodeRefactor = require("refactoring").select_refactor })
end

return L
