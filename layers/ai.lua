local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Artificial Intelligence" }

function L.plugins(s)
	setup.plugin(s, {
		"github/copilot.vim",
		"jackMort/ChatGPT.nvim",
		"MunifTanjim/nui.nvim",
	})
end

function L.settings(s)
	vim.g.copilot_no_tab_map = true
	require("chatgpt").setup({
		-- optional configuration
		keymaps = {
			close = { "<C-c>" },
			submit = {"<C-Enter>", "<C-s>"},
			yank_last = "<C-y>",
			yank_last_code = "<C-k>",
			scroll_up = "<C-u>",
			scroll_down = "<C-d>",
			toggle_settings = "<C-o>",
			new_session = "<C-n>",
			cycle_windows = "<Tab>",
			-- in the Sessions pane
			select_session = "<Space>",
			rename_session = "r",
			delete_session = "d",
		},
	})
	commands.implement(s, "*", {
		{ cmd.LYRDSmartCoder, ":Copilot" },
		{ cmd.LYRDAIAssistant, ":ChatGPT" },
		{ cmd.LYRDAIRefactor, ":ChatGPTEditWithInstructions" },
	})
end

return L
