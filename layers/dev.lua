local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")

local L = { name = "Development" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"tummetott/unimpaired.nvim",
			event = "VeryLazy",
			opts = {},
		}, -- use lazy.nvim
		{
			"numtostr/comment.nvim",
			opts = {
				hook = function()
					require("ts_context_commentstring").update_commentstring()
				end,
			},
			dependencies = {
				"joosepalviste/nvim-ts-context-commentstring",
			},
		},
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
		},
		{
			"gh-liu/fold_line.nvim",
			event = "VeryLazy",
			init = function()
				-- change the char of the line, see the `Appearance` section
				vim.g.fold_line_char_open_start = "╭"
				vim.g.fold_line_char_open_end = "╰"
			end,
		},
		{
			"joosepalviste/nvim-ts-context-commentstring",
			opts = {
				enable_autocmd = false,
			},
		},
		{ "norcalli/nvim-colorizer.lua" },
		{ "ellisonleao/dotenv.nvim", opts = {} },
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
			dependencies = {
				"hrsh7th/nvim-cmp",
			},
		},
		{
			"kylechui/nvim-surround",
			version = "*", -- Use for stability; omit to use `main` branch for the latest features
			event = "VeryLazy",
			opts = {},
		},
		{ -- This plugin
			"zeioth/compiler.nvim",
			cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
			dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
			opts = {},
		},
		{ -- This plugin
			"Zeioth/makeit.nvim",
			cmd = { "MakeitOpen", "MakeitToggleResults", "MakeitRedo" },
			dependencies = { "stevearc/overseer.nvim" },
			opts = {},
		},
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			opts = {
				enabled = true,
				exclude = {
					filetypes = {
						"",
						"NvimTree",
						"TelescopePrompt",
						"TelescopeResults",
						"Trouble",
						"checkhealth",
						"dashboard",
						"gitcommit",
						"help",
						"lazy",
						"lspinfo",
						"man",
						"neogitstatus",
						"packer",
						"startify",
						"text",
					},
					buftypes = {
						"terminal",
						"nofile",
						"quickfix",
						"prompt",
					},
				},
				indent = {
					char = icons.tree_lines.thin_left,
				},
			},
		},
		{
			"rest-nvim/rest.nvim",
		},
	})
end

function L.complete(_)
	-- If you want insert `(` after select function or method item
	local is_cmp_loaded, cmp = pcall(require, "cmp")
	if is_cmp_loaded then
		cmp.event:on(
			"confirm_done",
			require("nvim-autopairs.completion.cmp").on_confirm_done({
				tex = false,
			})
		)
	end
end

return L
