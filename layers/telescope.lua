local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"

local L = {name = 'Telescope'}

function L.plugins(s)
  setup.plugin(s, {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-telescope/telescope-ui-select.nvim'
  })
end

function L.settings(s)
  require('telescope').setup()
  require("telescope").load_extension("ui-select")

  commands.implement(s, '*', {
    LYRDSearchFiles = ':Telescope find_files',
    LYRDSearchBuffers = ':Telescope buffers',
    LYRDSearchGitFiles = ':Telescope git_files',
    LYRDSearchRecentFiles = ':Telescope oldfiles',
    LYRDSearchBufferLines = ':Telescope current_buffer_fuzzy_lines',
    LYRDSearchCommandHistory = ':Telescope command_history',
    LYRDSearchKeyMappings = ':Telescope keymaps',
    LYRDSearchBufferTags = ':Telescope current_buffer_tags',
    LYRDSearchLiveGrep = ':Telescope live_grep',
    LYRDSearchFiletypes = ':Telescope filetypes',
    LYRDSearchColorSchemes = ':Telescope colorscheme',
    LYRDSearchQuickFixes = ':Telescope quickfix',
    LYRDSearchRegisters = ':Telescope registers',
    LYRDSearchHighlights = ':Telescope highlights',
    LYRDSearchCurrentString = ':Telescope grep_string',
    LYRDSearchCommands = ':Telescope commands',
    LYRDGitModifiedFiles = ':Telescope git_status',
    LYRDGitBranches = ':Telescope git_branches',
    LYRDGitCommits = ':Telescope git_commits',
    LYRDGitBufferCommits = ':Telescope git_bcommits',
    LYRDGitStash = ':Telescope git_stash',
    LYRDLSPFindReferences = ':Telescope lsp_references',
    LYRDLSPFindDocumentSymbols = ':Telescope lsp_document_symbols',
    LYRDLSPFindWorkspaceSymbols = ':Telescope lsp_workspace_symbols',
    LYRDLSPFindDocumentDiagnostics = ':Telescope lsp_document_diagnostics',
    LYRDLSPFindWorkspaceDiagnostics = ':Telescope lsp_workspace_diagnostics',
    LYRDLSPFindImplementations = ':Telescope lsp_implementations',
    LYRDLSPFindDefinitions = ':Telescope lsp_definitions'
  })
end

return L
