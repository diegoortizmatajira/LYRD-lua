local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Artificial Intelligence" }

function L.plugins(s)
	setup.plugin(s, {
		"github/copilot.vim",
		"jackMort/ChatGPT.nvim",
		"MunifTanjim/nui.nvim",
		"james1236/backseat.nvim",
	})
end

function L.settings(s)
	vim.g.copilot_no_tab_map = true
	require("chatgpt").setup({
		-- optional configuration
		keymaps = {
			close = { "<C-c>" },
			submit = { "<C-Enter>", "<C-s>" },
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
	require("backseat").setup({
		-- Alternatively, set the env var $OPENAI_API_KEY by putting "export OPENAI_API_KEY=sk-xxxxx" in your ~/.bashrc
		-- openai_api_key = "sk-xxxxxxxxxxxxxx", -- Get yours from platform.openai.com/account/api-keys
		openai_model_id = "gpt-3.5-turbo", --gpt-4 (If you do not have access to a model, it says "The model does not exist")
		-- split_threshold = 100,
		-- additional_instruction = "Respond snarkily", -- (GPT-3 will probably deny this request, but GPT-4 complies)
		-- highlight = {
		--     icon = '', -- ''
		--     group = 'Comment',
		-- }
	})
	commands.implement(s, "*", {
		{ cmd.LYRDSmartCoder, ":Copilot" },
		{ cmd.LYRDAIAssistant, ":ChatGPT" },
		{ cmd.LYRDAIRefactor, ":ChatGPTEditWithInstructions" },
		{ cmd.LYRDAISuggestions, ":Backseat" },
	})
end

return L
