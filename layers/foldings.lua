local icons = require("LYRD.layers.icons")
local setup = require("LYRD.shared.setup")

---@class LYRD.layer.Foldings: LYRD.shared.setup.Module
local L = { name = "Code Foldings" }

function L.plugins()
	setup.plugin({
		{
			"kevinhwang91/nvim-ufo",
			dependencies = { "kevinhwang91/promise-async" },
			opts = {
				provider_selector = function()
					return {
						"treesitter",
						"indent",
					}
				end,
			},
			init = function()
				vim.o.foldcolumn = "1" -- '0' is not bad
				vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
				vim.o.foldlevelstart = 99
				vim.o.foldenable = true
			end,
			-- enabled = false,
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
	})
end

return L
