local setup = require("LYRD.setup")

local L = { name = "Development" }

function L.plugins(s)
	setup.plugin(s, {
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
		{ -- The task runner we use
			"stevearc/overseer.nvim",
			opts = {
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
				},
			},
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
					char = "▏",
				},
			},
		},
	})
end

function L.settings(_)
	-- TODO: Include on CMP
	-- -- If you want insert `(` after select function or method item
	-- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
	-- local cmp = require('cmp')
	-- cmp.event:on(
	--   'confirm_done',
	--   cmp_autopairs.on_confirm_done()
	-- )
end

return L
