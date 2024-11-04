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
		{ cmd.LYRDSearchColorSchemes, ":Telescope colorscheme" },
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
	})
end

return L
