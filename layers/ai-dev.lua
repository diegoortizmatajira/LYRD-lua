local setup = require("LYRD.shared.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local keyboard = require("LYRD.layers.lyrd-keyboard")

local ai_providers = {
	COPILOT = "copilot",
	CODEIUM = "codeium",
	TABNINE = "tabnine",
}

---@class LYRD.layer.AIDev: LYRD.shared.setup.Module
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

local function sidekick_nvim_env()
	return {
		NVIM = vim.v.servername,
	}
end

--- Treesitter node types that represent documentable elements.
local documentable_node_types = {
	"function_definition",
	"function_declaration",
	"method_definition",
	"method_declaration",
	"class_definition",
	"class_declaration",
	"class_specifier",
	"struct_item",
	"enum_item",
	"impl_item",
	"function_item",
	"interface_declaration",
	"type_alias_declaration",
	"export_statement",
	"lexical_declaration",
	"variable_declaration",
	"field_definition",
}

--- Finds the nearest documentable treesitter node at the cursor and returns its line range.
---@return integer|nil start_line 1-indexed start line
---@return integer|nil end_line 1-indexed end line
local function find_documentable_node_range()
	local node = vim.treesitter.get_node()
	if not node then
		return nil, nil
	end
	local type_set = {}
	for _, t in ipairs(documentable_node_types) do
		type_set[t] = true
	end
	while node do
		if type_set[node:type()] then
			local start_row, _, end_row, _ = node:range()
			return start_row + 1, end_row + 1
		end
		node = node:parent()
	end
	return nil, nil
end

--- Generates documentation for the element at the cursor using treesitter to find its full range.
local function generate_documentation()
	local start_line, end_line = find_documentable_node_range()
	if not start_line or not end_line then
		vim.notify("No documentable element found at cursor", vim.log.levels.WARN)
		return
	end
	require("avante.api").edit(L.documentation_prompt, start_line, end_line)
end

--- Finds the Neogit status panel window, if open.
---@return integer|nil winid
local function find_neogit_status_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "NeogitStatus" then
			return win
		end
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
	local diff_line_count = #lines
	local commit_win = vim.api.nvim_get_current_win()
	vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
	require("avante.api").edit(L.commit_message_prompt, 1, diff_line_count)
	-- Avante's PromptInput floating window corrupts Neovim's prevwin chain.
	-- When the commit editor later closes on Submit, Neovim can't find its way
	-- back to the Neogit status panel. Fix both hops of the chain:
	-- 1. After PromptInput closes: restore focus to commit editor with correct prevwin
	-- 2. After commit editor closes: ensure focus lands on Neogit status panel
	local prompt_buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_is_valid(prompt_buf) and vim.bo[prompt_buf].filetype == "AvantePromptInput" then
		vim.api.nvim_create_autocmd("BufDelete", {
			buffer = prompt_buf,
			once = true,
			callback = function()
				vim.schedule(function()
					if not vim.api.nvim_win_is_valid(commit_win) then
						return
					end
					-- Restore prevwin chain: briefly visit status panel, then return to commit editor.
					-- This makes Neovim's prevwin for the commit editor point to the status panel.
					local status_win = find_neogit_status_win()
					if status_win and vim.api.nvim_win_is_valid(status_win) then
						vim.api.nvim_set_current_win(status_win)
					end
					vim.api.nvim_set_current_win(commit_win)
				end)
			end,
		})
	end
	-- Fallback: when the commit editor window closes, explicitly focus the status panel.
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(commit_win),
		once = true,
		callback = function()
			vim.schedule(function()
				local status_win = find_neogit_status_win()
				if status_win and vim.api.nvim_win_is_valid(status_win) then
					vim.api.nvim_set_current_win(status_win)
				end
			end)
		end,
	})
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
						accept = false, -- Mapped manually to avoid expr mapping bug with special keys
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
					accept_fallback = keyboard.ai_keys.accept,
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
					tools = {
						claude = { env = sidekick_nvim_env() },
						codex = { env = sidekick_nvim_env() },
						copilot = { env = sidekick_nvim_env() },
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
	-- Manual accept mapping for copilot to avoid expr mapping bug that inserts raw keycodes
	if L.completion_provider == ai_providers.COPILOT then
		vim.keymap.set("i", keyboard.ai_keys.accept, function()
			local ok, suggestion = pcall(require, "copilot.suggestion")
			if ok and suggestion.is_visible() then
				suggestion.accept()
			else
				local key = vim.api.nvim_replace_termcodes(keyboard.ai_keys.accept, true, false, true)
				vim.api.nvim_feedkeys(key, "n", false)
			end
		end, { desc = "[copilot] accept suggestion", silent = true })
	end
	commands.implement("gitcommit", {
		{ cmd.LYRDAIGenerateDocumentation, generate_commit_message },
	})
	commands.implement("*", {
		{ cmd.LYRDSmartCoder, ":AvanteEdit" },
		{ cmd.LYRDAIGenerateDocumentation, generate_documentation },
		{ cmd.LYRDAIAssistant, ":AvanteToggle" },
		{ cmd.LYRDAICli, ":Sidekick cli toggle" },
		{ cmd.LYRDAICliSelect, ":Sidekick cli select" },
		{ cmd.LYRDAICliPrompt, ":Sidekick cli prompt" },
		{ cmd.LYRDAIAsk, ":AvanteAsk" },
		{ cmd.LYRDAIEdit, ":AvanteEdit" },
	})
end

return L
