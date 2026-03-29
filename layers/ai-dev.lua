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
	commit_message_prompt = [[
Generate a concise git commit message from the diff below.

Format:
<type>: <summary in imperative mood, max 72 chars>

- <what changed and why>
- <what changed and why>

Where <type> is one of: feat, fix, refactor, docs, style, test, chore, perf.

Rules:
- The summary line must describe the SPECIFIC change, not a category. Bad: "Update code". Good: "Add retry logic to S3 upload handler".
- Each bullet must name the concrete thing that changed (file, function, config key, behavior) and why.
- If the diff adds something, say what was added. If it removes something, say what was removed. If it changes behavior, describe the old vs new behavior.
- Do NOT use filler like "improve maintainability" or "enhance functionality" — be specific about what improved and how.
- Write in imperative mood ("Add", "Fix", "Remove", not "Added", "Fixed", "Removed").
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

--- Creates a function that triggers an Avante edit with a predefined prompt.
--- The returned function accepts an options table with optional `args`, `line1`, and `line2` fields.
--- If `args` is provided and the `prompt` parameter is nil, the trimmed `args` will be used as the prompt.
---@param prompt string|nil The predefined prompt to use for the edit. If nil, `opts.args` is used instead.
---@return fun(opts?: {args?: string, line1?: integer, line2?: integer}) handler A function that invokes `avante.api.edit` with the resolved prompt and line range.
local function edit_with_prompt(prompt)
	return function(opts)
		opts = opts or {}
		require("avante.api").edit(prompt or vim.trim(opts.args or ""), opts.line1, opts.line2)
	end
end

--- Generates a commit message by injecting the staged diff into the current buffer and invoking Avante edit.
local function generate_commit_message()
	local diff = vim.fn.system("git diff --cached")
	if vim.v.shell_error ~= 0 or diff == "" then
		vim.notify("No staged changes found. Stage your changes first.", vim.log.levels.WARN)
		return
	end
	local lines = vim.split(diff, "\n")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	local line_count = vim.api.nvim_buf_line_count(0)
	require("avante.api").edit(L.commit_message_prompt, 1, line_count)
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
					} or {},
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
					manual = false,
					filetypes = {},
					default_filetype_enabled = true,
					idle_delay = 75,
					virtual_text_priority = 65535,
					map_keys = true,
					accept_fallback = nil,
					key_bindings = {
						accept = keyboard.ai_keys.accept,
						accept_word = keyboard.ai_keys.accept_word,
						accept_line = keyboard.ai_keys.accept_line,
						clear = keyboard.ai_keys.clear,
						next = keyboard.ai_keys.next,
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
			lazy = false,
			version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
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
				-- This is explicit mappings in options for sidekick
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
	commands.implement("gitcommit", {
		{ cmd.LYRDAIGenerateDocumentation, generate_commit_message },
	})
	commands.implement("*", {
		{ cmd.LYRDSmartCoder, ":AvanteEdit" },
		{ cmd.LYRDAIGenerateDocumentation, edit_with_prompt(L.documentation_prompt) },
		{ cmd.LYRDAIAssistant, ":AvanteToggle" },
		{ cmd.LYRDAICli, ":Sidekick cli toggle" },
		{ cmd.LYRDAICliSelect, ":Sidekick cli select" },
		{ cmd.LYRDAICliPrompt, ":Sidekick cli prompt" },
		{ cmd.LYRDAIAsk, ":AvanteAsk" },
		{ cmd.LYRDAIEdit, ":AvanteEdit" },
	})
end

return L
