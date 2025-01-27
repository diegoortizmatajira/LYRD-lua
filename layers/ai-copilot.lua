local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "AI - Copilot" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"github/copilot.vim",
			init = function()
				vim.g.copilot_no_tab_map = true
				vim.g.copilot_hide_during_completion = 0
				vim.g.copilot_proxy_strict_ssl = 0
				vim.g.copilot_filetypes = {
					["*"] = false,
				}
				vim.g.copilot_no_tab_map = true
			end,
		},
		{
			"CopilotC-Nvim/CopilotChat.nvim",
			dependencies = {
				{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
				{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
			},
			build = "make tiktoken", -- Only on MacOS or Linux
			opts = {
				-- See Configuration section for options
			},
			-- See Commands section for default commands if you want to lazy load on them
		},
	})
end

function L.settings(s)
	commands.implement("*", {
		{ cmd.LYRDSmartCoder, ":Copilot" },
	})
end

return L
