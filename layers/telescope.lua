local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Telescope" }

function L.plugins(s)
	setup.plugin(s, {
		"nvim-lua/popup.nvim",
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("fzf")
			end,
			build = "make",
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"nvim-telescope/telescope-ui-select.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("ui-select")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"benfowler/telescope-luasnip.nvim",
			config = function()
				local telescope = require("telescope")
				telescope.load_extension("luasnip")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"nvim-telescope/telescope.nvim",
			opts = {},
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope-fzf-native.nvim",
				"nvim-telescope/telescope-ui-select.nvim",
			},
		},
	})
end

function L.select_file_and_execute(callback, title, filter, working_directory)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local builtin = require("telescope.builtin")
	builtin.find_files({
		prompt_title = title or "Select a file",
		cwd = working_directory or vim.fn.getcwd(), -- Set the current working directory
		find_command = { "find", ".", "-type", "f", "-name", filter or "*.*" },
		attach_mappings = function(prompt_bufnr, map)
			local function on_select()
				local selected_entry = action_state.get_selected_entry()
				local file_path = selected_entry.path or selected_entry.filename
				actions.close(prompt_bufnr)
				callback(file_path) -- Call the callback function with the selected file path
			end
			map("i", "<CR>", on_select)
			map("n", "<CR>", on_select)
			return true
		end,
	})
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDSearchFiles, ":Telescope find_files" },
		{ cmd.LYRDSearchBuffers, ":Telescope buffers" },
		{ cmd.LYRDSearchGitFiles, ":Telescope git_files" },
		{ cmd.LYRDSearchRecentFiles, ":Telescope oldfiles" },
		{ cmd.LYRDSearchBufferLines, ":Telescope current_buffer_fuzzy_lines" },
		{ cmd.LYRDSearchCommandHistory, ":Telescope command_history" },
		{ cmd.LYRDSearchKeyMappings, ":Telescope keymaps" },
		{ cmd.LYRDSearchBufferTags, ":Telescope current_buffer_tags" },
		{ cmd.LYRDSearchLiveGrep, ":Telescope live_grep" },
		{ cmd.LYRDSearchFiletypes, ":Telescope filetypes" },
		{ cmd.LYRDSearchQuickFixes, ":Telescope quickfix" },
		{ cmd.LYRDSearchRegisters, ":Telescope registers" },
		{ cmd.LYRDSearchHighlights, ":Telescope highlights" },
		{ cmd.LYRDSearchCurrentString, ":Telescope grep_string" },
		{ cmd.LYRDSearchCommands, ":Telescope commands" },
		{ cmd.LYRDLSPFindReferences, ":Telescope lsp_references" },
		{ cmd.LYRDLSPFindDocumentSymbols, ":Telescope lsp_document_symbols" },
		{ cmd.LYRDLSPFindWorkspaceSymbols, ":Telescope lsp_workspace_symbols" },
		{ cmd.LYRDLSPFindDocumentDiagnostics, ":Telescope lsp_document_diagnostics" },
		{ cmd.LYRDLSPFindWorkspaceDiagnostics, ":Telescope lsp_workspace_diagnostics" },
		{ cmd.LYRDLSPFindImplementations, ":Telescope lsp_implementations" },
		{ cmd.LYRDLSPFindDefinitions, ":Telescope lsp_definitions" },
		{ cmd.LYRDResumeLastSearch, ":Telescope resume" },
		{ cmd.LYRDCodeInsertSnippet, "Telescope luasnip" },
	})
end

return L
