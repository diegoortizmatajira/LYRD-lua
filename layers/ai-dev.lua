local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local keyboard = require("LYRD.layers.lyrd-keyboard")

local ai_providers = {
	COPILOT = "copilot",
	CODEIUM = "codeium",
	TABNINE = "tabnine",
}

---@class LYRD.layer.AIDev: LYRD.setup.Module
local L = {
	name = "AI Assistance",
	avante_provider = ai_providers.COPILOT,
	completion_provider = ai_providers.COPILOT,
	documentation_prompt = [[
	Ensure the current element is well documented by generating or updating its
	documentation annotations to reflect the current code. Do not add or modify
	child elements documentation.
	]],
}

local function avante_dependencies()
	local result = {

		"nvim-lua/plenary.nvim",
		"muniftanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"HakonHarnes/img-clip.nvim",
		"MeanderingProgrammer/render-markdown.nvim",
	}
	if L.avante_provider == ai_providers.COPILOT then
		table.insert(result, "zbirenbaum/copilot.lua")
	end
	return result
end

local function edit_with_prompt(prompt)
	return function(opts)
		opts = opts or {}
		require("avante.api").edit(prompt or vim.trim(opts.args), opts.line1, opts.line2)
	end
end

function L.plugins()
	setup.plugin({

		{
			"zbirenbaum/copilot.lua",
			--- Gets loaded if either avante or completion provider is copilot
			enabled = L.avante_provider == ai_providers.COPILOT or L.completion_provider == ai_providers.COPILOT,
			opts = {
				suggestion = {
					enabled = true,
					auto_trigger = L.completion_provider == ai_providers.COPILOT,
					hide_during_completion = true,
					debounce = 75,
					keymap = L.completion_provider == ai_providers.COPILOT and {
						accept = keyboard.ai_keys.accept,
						accept_word = keyboard.ai_keys.accept_word,
						accept_line = keyboard.ai_keys.accept_line,
						next = keyboard.ai_keys.next,
						prev = keyboard.ai_keys.prev,
						dismiss = keyboard.ai_keys.clear,
					},
					copilot_model = "", -- Current LSP default is gpt-35-turbo, supports gpt-4o-copilot
				},
			},
			cmd = "Copilot",
			event = "InsertEnter",
		},
		{
			"Exafunction/codeium.nvim",
			--- Only gets loaded if completion provider is codeium
			enabled = L.completion_provider == ai_providers.CODEIUM,
			opts = {
				virtual_text = {
					enabled = true,
					-- Set to true if you never want completions to be shown automatically.
					manual = false,
					-- A mapping of filetype to true or false, to enable virtual text.
					filetypes = {},
					-- Whether to enable virtual text of not for filetypes not specifically listed above.
					default_filetype_enabled = true,
					-- How long to wait (in ms) before requesting completions after typing stops.
					idle_delay = 75,
					-- Priority of the virtual text. This usually ensures that the completions appear on top of
					-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
					-- desired.
					virtual_text_priority = 65535,
					-- Set to false to disable all key bindings for managing completions.
					map_keys = true,
					-- The key to press when hitting the accept keybinding but no completion is showing.
					-- Defaults to \t normally or <c-n> when a popup is showing.
					accept_fallback = nil,
					-- Key bindings for managing completions in virtual text mode.
					key_bindings = {
						-- Accept the current completion.
						accept = keyboard.ai_keys.accept,
						-- Accept the next word.
						accept_word = keyboard.ai_keys.accept_word,
						-- Accept the next line.
						accept_line = keyboard.ai_keys.accept_line,
						-- Clear the virtual text.
						clear = keyboard.ai_keys.clear,
						-- Cycle to the next completion.
						next = keyboard.ai_keys.next,
						-- Cycle to the previous completion.
						prev = keyboard.ai_keys.prev,
					},
				},
				enable_cmp_source = true,
			},
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
		{
			"codota/tabnine-nvim",
			--- Only gets loaded if completion provider is tabnine
			enabled = L.completion_provider == ai_providers.TABNINE,
			opts = {
				disable_auto_comment = true,
				accept_keymap = keyboard.ai_keys.accept,
				dismiss_keymap = keyboard.ai_keys.clear,
				debounce_ms = 800,
				suggestion_color = { gui = "#808080", cterm = 244 },
				exclude_filetypes = { "TelescopePrompt", "NvimTree" },
				log_file_path = nil, -- absolute path to Tabnine log file
				ignore_certificate_errors = false,
			},
			main = "tabnine",
			build = "./dl_binaries.sh",
		},
		{
			"tzachar/cmp-tabnine",
			--- Only gets loaded if completion provider is tabnine
			enabled = L.completion_provider == ai_providers.TABNINE,
			build = "./install.sh",
			dependencies = {
				"hrsh7th/nvim-cmp",
				"codota/tabnine-nvim",
			},
		},
		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			lazy = false,
			version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
			-- version = "v0.0.20",
			opts = {
				provider = L.avante_provider,
				auto_suggestions_provider = L.avante_provider,
				mapping = {
					ask = false,
					edit = false,
				},
			},
			-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
			build = "make",
			-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
			dependencies = avante_dependencies(),
		},
		{
			"folke/sidekick.nvim",
			opts = {
				-- add any options here
				cli = {
					mux = {
						backend = "tmux",
						enabled = true,
					},
				},
				nes = {
					enabled = false,
				},
				keys = {
					{
						"<tab>",
						function()
							-- if there is a next edit, jump to it, otherwise apply it if any
							if not require("sidekick").nes_jump_or_apply() then
								return "<Tab>" -- fallback to normal tab
							end
						end,
						expr = true,
						desc = "Goto/Apply Next Edit Suggestion",
					},
				},
			},
		},
	})
end

function L.settings()
	local wrap = require("LYRD.layers.commands").wrap
	commands.implement("*", {
		{ cmd.LYRDSmartCoder, ":AvanteEdit" },
		{ cmd.LYRDAIGenerateDocumentation, edit_with_prompt(L.documentation_prompt) },
		{ cmd.LYRDAIAssistant, ":AvanteToggle" },
		{ cmd.LYRDAICli, ":Sidekick cli toggle" },
		{ cmd.LYRDAIAsk, wrap(require("avante.api").ask) },
		{ cmd.LYRDAIEdit, wrap(require("avante.api").edit) },
	})
end

return L
