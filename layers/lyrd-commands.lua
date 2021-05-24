local setup = require "setup"
local commands = require "layers.commands"
local mappings = require "layers.mappings"
local c = commands.command_shortcut

local L = {name = 'LYRD Commands'}

function L.settings(s)
    commands.register(s, {
        LYRDUnimplementedCommands = ':lua require("layers.commands").list_unimplemented()',
        LYRDBufferNew = ':enew',
        LYRDBufferSave = ':w',
        LYRDBufferSaveAll = ':wall',
        LYRDBufferClose = ':bd',
        LYRDBufferForceClose = ':bd!',
        LYRDBufferCloseAll = ':bufdo bd',
        LYRDBufferForceCloseAll = ':bufdo bd!',
        LYRDBufferFormat = '',
        LYRDBufferJumpToLast = ':b#',
        LYRDBufferNext = ':bn',
        LYRDBufferPrev = ':bp',
        LYRDBufferSplitV = ':<C-u>vsplit',
        LYRDBufferSplitH = ':<C-u>split',
        LYRDBufferSetReadOnly = ':setl readonly!',
        LYRDBufferCopy = ':normal! ggVG"+y``',
        LYRDBufferPaste = ':normal! ggdG"+P',
        LYRDBufferToggleWrap = ':setlocal wrap!',
        LYRDWindowClose = ':q',
        LYRDWindowCloseAll = ':qa',
        LYRDWindowForceCloseAll = ':qa!',
        LYRDViewErrorList = '',
        LYRDViewYankList = '',
        LYRDViewFileTree = '',
        LYRDViewFileExplorer = '',
        LYRDPluginsInstall = ':PlugInstall',
        LYRDPluginsUpdate = ':PlugClean',
        LYRDPluginsClean = ':PlugClean',
        LYRDTerminal = ':terminal',
        LYRDSearchFiles = '',
        LYRDSearchBuffers = '',
        LYRDSearchGitFiles = '',
        LYRDSearchRecentFiles = '',
        LYRDSearchBufferLines = '',
        LYRDSearchCommandHistory = '',
        LYRDSearchKeyMappings = '',
        LYRDSearchBufferTags = '',
        LYRDSearchLiveGrep = '',
        LYRDSearchFiletypes = '',
        LYRDSearchColorSchemes = '',
        LYRDSearchQuickFixes = '',
        LYRDSearchRegisters = '',
        LYRDSearchHighlights = '',
        LYRDSearchCurrentString = '',
        LYRDSearchCommands = '',
        LYRDGitModifiedFiles = '',
        LYRDGitBranches = '',
        LYRDGitCommits = '',
        LYRDGitBufferCommits = '',
        LYRDGitStash = '',
        LYRDLSPFindReferences = '',
        LYRDLSPFindDocumentSymbols = '',
        LYRDLSPFindWorkspaceSymbols = '',
        LYRDLSPFindCodeActions = '',
        LYRDLSPFindRangeCodeActions = '',
        LYRDLSPFindDocumentDiagnostics = '',
        LYRDLSPFindWorkspaceDiagnostics = '',
        LYRDLSPFindImplementations = '',
        LYRDLSPFindDefinitions = '',
        LYRDCodeInsertSnippet = ''
    })
end

function L.keybindings(s)

    mappings.space_menu(s, {
        {{'g'}, 'Git Repository'},
        {{'a'}, 'Actions'},
        {{'A'}, 'Application'},
        {{'b'}, 'Buffers'},
        {{'c'}, 'Code'},
        {{'f'}, 'Files'},
        {{'p'}, 'Plugins'},
        {{'q'}, 'Quit'},
        {{'s'}, 'Search'},
        {{'u'}, 'User interface'},
        {{'v'}, 'View'}
    })
    mappings.space(s, {
        {'n', {'<Tab>'}, c('LYRDBufferJumpToLast'), 'Jump to last buffer'},
        -- View Menu
        {'n', {'v', 'l'}, c('LYRDViewErrorList'), 'List all errors'},
        {'n', {'v', 'r'}, c('LYRDViewRegisters'), 'Registers'},
        {'n', {'v', 'y'}, c('LYRDViewYankList'), 'Yank list'},
        -- Buffer Menu
        {'n', {'b', '>'}, c('LYRDBufferNext'), 'Next buffer'},
        {'n', {'b', '<'}, c('LYRDBufferPrev'), 'Previous buffer'},
        {'n', {'b', 'd'}, c('LYRDBufferClose'), 'Close buffer'},
        {'n', {'b', 'D'}, c('LYRDBufferForceClose'), 'Force close buffer'},
        {'n', {'b', 'x'}, c('LYRDBufferCloseAll'), 'Close all buffers'},
        {'n', {'b', 'f'}, c('LYRDBufferFormat'), 'Format document'},
        {'n', {'b', 'X'}, c('LYRDBufferForceCloseAll'), 'Force close all buffers'},
        {'n', {'b', 'h'}, c('LYRDBufferSplitH'), 'Horizonal split'},
        {'n', {'b', 'v'}, c('LYRDBufferSplitV'), 'Vertical split'},
        {'n', {'b', 'w'}, c('LYRDBufferSetReadOnly'), 'Toggle read only mode'},
        {'n', {'b', 'Y'}, c('LYRDBufferCopy'), 'Copy whole buffer to clipboard'},
        {'n', {'b', 'P'}, c('LYRDBufferPaste'), 'Paste clipboard to whole buffer'},
        {'n', {'b', 'n'}, c('LYRDBufferNew'), 'New empty buffer'},
        {'n', {'b', '/'}, c('LYRDSearchBuffers'), 'Buffer list'},
        -- File Menu
        {'n', {'f', 's'}, c('LYRDBufferSave'), 'Save current file'},
        {'n', {'f', 'S'}, c('LYRDBufferSaveAll'), 'Save all files'},
        {'n', {'f', 't'}, c('LYRDViewFileTree'), 'Toggle file tree'},
        {'n', {'f', 'e'}, c('LYRDViewFileExplorer'), 'Explore files'},
        {'n', {'f', '.'}, c('LYRDSearchFiles'), 'Find files'},
        -- Application Menu
        {'n', {'A', 'i'}, c('LYRDPluginsInstall'), 'Install plugins'},
        {'n', {'A', 'u'}, c('LYRDPluginsUpdate'), 'Update plugins'},
        {'n', {'A', 'c'}, c('LYRDPluginsClean'), 'Clean plugins'},
        {'n', {'A', 't'}, c('LYRDTerminal'), 'Terminal'},
        -- Quit Menu
        {'n', {'q', '.'}, c('LYRDWindowClose'), 'Close window'},
        {'n', {'q', 'q'}, c('LYRDWindowForceCloseAll'), 'Quit'},
        {'n', {'q', 'Q'}, c('LYRDWindowForceCloseAll'), 'Force Quit'},
        -- UI Menu
        {'n', {'u', 'w'}, c('LYRDBufferToggleWrap'), 'Toggle line wrap'},
        -- Search Menu
        {'n', {'s', '.'}, c('LYRDSearchFiles'), 'Files'},
        {'n', {'s', 'b'}, c('LYRDSearchBuffers'), 'Buffers'},
        {'n', {'s', 'g'}, c('LYRDSearchGitFiles'), 'Git Files'},
        {'n', {'s', 'h'}, c('LYRDSearchRecentFiles'), 'Recent files'},
        {'n', {'s', 'l'}, c('LYRDSearchBufferLines'), 'Lines'},
        {'n', {'s', 'c'}, c('LYRDSearchCommandHistory'), 'Recent comands'},
        {'n', {'s', 'm'}, c('LYRDSearchKeyMappings'), 'Key Maps'},
        {'n', {'s', 't'}, c('LYRDSearchBufferTags'), 'Tags'},
        {'n', {'s', '/'}, c('LYRDSearchLiveGrep'), 'Live grep'},
        {'n', {'s', 'f'}, c('LYRDSearchFiletypes'), 'Filetypes'},
        {'n', {'s', 'o'}, c('LYRDSearchColorSchemes'), 'Color Schemes'},
        {'n', {'s', 'q'}, c('LYRDSearchQuickFixes'), 'Quick Fixes'},
        {'n', {'s', 'H'}, c('LYRDSearchHighlights'), 'Highlights'},
        {'n', {'s', ','}, c('LYRDSearchCommands'), 'Commands'},
        {'n', {'s', 's'}, c('LYRDSearchCurrentString'), 'Current string in files'},
        {'n', {'s', 'p'}, c('LYRDSearchRegisters'), 'Registers'},
        -- Git Menu
        {'n', {'g', 'm'}, c('LYRDGitModifiedFiles'), 'Modified files'},
        {'n', {'g', 'B'}, c('LYRDGitBranches'), 'Branches'},
        -- Code Menu
        {'n', {'c', 's'}, c('LYRDCodeInsertSnippet'), 'Insert snippet'}
    })
end

return L
