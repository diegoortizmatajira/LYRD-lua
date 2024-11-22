local setup = require("LYRD.setup")
local keyboard = require("LYRD.layers.lyrd-keyboard")

local L = { name = "Codeium AI" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"Exafunction/codeium.nvim",
			opts = {
				enable_cmp_source = true,
				virtual_text = {
					enabled = true,

					-- These are the defaults

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
			},
			dependencies = {
				"nvim-lua/plenary.nvim",
				"hrsh7th/nvim-cmp",
			},
		},
	})
end

function L.settings(_) end

return L
