local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Foldings" }

function L.plugins()
	setup.plugin({
		{
			"kevinhwang91/nvim-ufo",
			dependencies = { "kevinhwang91/promise-async" },
			opts = {
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			},
			init = function()
				vim.o.foldcolumn = "1" -- '0' is not bad
				vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
				vim.o.foldlevelstart = 99
				vim.o.foldenable = true
			end,
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

function L.preparation() end

function L.settings()
	-- local lsp = require("LYRD.layers.lsp")
	-- lsp.plug_capabilities(function(capabilities)
	-- 	capabilities.textDocument.foldingRange = {
	-- 		dynamicRegistration = false,
	-- 		lineFoldingOnly = true,
	-- 	}
	-- 	return capabilities
	-- end)
	commands.implement("*", {
		-- { cmd.LYRDXXXX, ":XXXXX" },
	})
end

function L.keybindings() end

function L.complete() end

return L
