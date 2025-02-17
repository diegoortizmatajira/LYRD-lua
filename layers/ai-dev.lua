local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local keyboard = require("LYRD.layers.lyrd-keyboard")

--- @class ai_provider
--- @field name string Name of the provider
--- @field plugins fun(suggestion_enabled: boolean): table function that returns a list of plugins for the provider, taking a boolean parameter

--- @type table<string,ai_provider>
local ai_providers = {
	COPILOT = {
		name = "copilot",
		plugins = function(suggestion_enabled)
			return {
				{
					"zbirenbaum/copilot.lua",
					opts = {
						suggestion = {
							enabled = true,
							auto_trigger = suggestion_enabled,
							hide_during_completion = true,
							debounce = 75,
							keymap = suggestion_enabled and {
								accept = keyboard.ai_keys.accept,
								accept_word = keyboard.ai_keys.accept_word,
								accept_line = keyboard.ai_keys.accept_line,
								next = keyboard.ai_keys.next,
								prev = keyboard.ai_keys.prev,
								dismiss = keyboard.ai_keys.clear,
							},
						},
					},
					cmd = "Copilot",
					event = "InsertEnter",
				},
			}
		end,
	},
	CODEIUM = {
		name = "codeium",
		plugins = function(suggestion_enabled)
			return {
				{
					"Exafunction/codeium.nvim",
					opts = {
						virtual_text = {
							enabled = suggestion_enabled,
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
							map_keys = suggestion_enabled,
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
			}
		end,
	},
	TABNINE = {
		name = "tabnine",
		plugins = function(_)
			return {
				{
					"codota/tabnine-nvim",
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
					build = "./install.sh",
					dependencies = {
						"hrsh7th/nvim-cmp",
						"codota/tabnine-nvim",
					},
				},
			}
		end,
	},
}

---@diagnostic disable-next-line: unused-function
local function completion_provider()
	---@diagnostic disable-next-line: undefined-field
	local uname = vim.loop.os_uname()
	if uname.sysname == "Darwin" then
		return ai_providers.COPILOT
	else
		return ai_providers.CODEIUM
	end
end

local L = {
	name = "AI Assistance",
	avante_provider = ai_providers.COPILOT,
	-- completion_provider = completion_provider(),
	completion_provider = ai_providers.COPILOT,
}

local function avante_dependencies()
	local result = {

		"stevearc/dressing.nvim",
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

function L.plugins()
	setup.plugin({
		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			lazy = false,
			version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
			opts = {
				provider = L.avante_provider.name,
				auto_suggestions_provider = L.avante_provider.name,
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
	})
	if L.avante_provider == L.completion_provider then
		setup.plugin(L.avante_provider.plugins(true))
	else
		setup.plugin(L.avante_provider.plugins(false))
		setup.plugin(L.completion_provider.plugins(true))
	end
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDAIAssistant, ":AvanteToggle" },
		{
			cmd.LYRDAIAsk,
			function()
				require("avante.api").ask()
			end,
		},
		{
			cmd.LYRDAIEdit,
			function()
				require("avante.api").edit()
			end,
		},
	})
end

return L
