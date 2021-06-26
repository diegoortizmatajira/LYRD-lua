local commands = require"LYRD.layers.commands"
local mappings = require"LYRD.layers.mappings"
local c = commands.command_shortcut
local e = commands.expression_shortcut

local L = {name = 'LYRD Commands'}

function L.settings(s)
  commands.register(s, {
    LYRDUnimplementedCommands = ':lua require("LYRD.layers.commands").list_unimplemented()',
    LYRDImplementedCommands = ':lua require("LYRD.layers.commands").list_implemented()',
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
    LYRDBufferSplitV = ':vsplit',
    LYRDBufferSplitH = ':split',
    LYRDBufferSetReadOnly = ':setl readonly!',
    LYRDBufferCopy = ':normal! ggVG"+y``',
    LYRDBufferPaste = ':normal! ggdG"+P',
    LYRDBufferToggleWrap = ':setlocal wrap!',
    LYRDWindowClose = ':q',
    LYRDWindowCloseAll = ':qa',
    LYRDWindowForceCloseAll = ':qa!',
    LYRDViewHomePage = '',
    LYRDViewLocationList = '',
    LYRDViewQuickFixList = ':cope',
    LYRDViewYankList = '',
    LYRDViewFileTree = '',
    LYRDViewFileExplorer = '',
    LYRDPluginsInstall = ':PlugInstall',
    LYRDPluginsUpdate = ':PlugUpdate',
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
    LYRDGitStatus = '',
    LYRDGitStageCurrentFile = '',
    LYRDGitUnstageCurrentFile = '',
    LYRDGitCommit = '',
    LYRDGitWrite = '',
    LYRDGitPush = '',
    LYRDGitPull = '',
    LYRDGitViewDiff = '',
    LYRDGitStageAll = '',
    LYRDGitViewBlame = '',
    LYRDGitRemove = '',
    LYRDGitViewCurrentFileLog = '',
    LYRDGitViewLog = '',
    LYRDGitBrowseOnWeb = '',
    LYRDGitFlowInit = '',
    LYRDGitFlowFeatureStart = '',
    LYRDGitFlowFeatureFinish = '',
    LYRDGitFlowReleaseStart = '',
    LYRDGitFlowReleaseFinish = '',
    LYRDGitFlowHotfixStart = '',
    LYRDGitFlowHotfixFinish = '',
    LYRDGitCheckoutMain = '',
    LYRDGitCheckoutDev = '',
    LYRDLSPFindReferences = '',
    LYRDLSPFindDocumentSymbols = '',
    LYRDLSPFindWorkspaceSymbols = '',
    LYRDLSPFindCodeActions = '',
    LYRDLSPFindRangeCodeActions = '',
    LYRDLSPFindLineDiagnostics = '',
    LYRDLSPFindDocumentDiagnostics = '',
    LYRDLSPFindWorkspaceDiagnostics = '',
    LYRDLSPFindImplementations = '',
    LYRDLSPFindDefinitions = '',
    LYRDLSPFindDeclaration = '',
    LYRDLSPHoverInfo = '',
    LYRDLSPSignatureHelp = '',
    LYRDLSPFindTypeDefinition = '',
    LYRDLSPRename = '',
    LYRDLSPGotoNextDiagnostic = '',
    LYRDLSPGotoPrevDiagnostic = '',
    LYRDLSPShowDocumentDiagnosticLocList = '',
    LYRDLSPShowWorkspaceDiagnosticLocList = '',
    LYRDCodeInsertSnippet = '',
    LYRDTest = '',
    LYRDTestSuite = '',
    LYRDTestFile = '',
    LYRDTestFunc = '',
    LYRDTestLast = '',
    LYRDCodeBuild = '',
    LYRDCodeRun = '',
    LYRDTestCoverage = '',
    LYRDDebugStart = '',
    LYRDDebugBreakpoint = '',
    LYRDCodeAlternateFile = '',
    LYRDCodeFixImports = '',
    LYRDCodeGlobalCheck = '',
    LYRDCodeImplementInterface = '',
    LYRDCodeFillStructure = '',
    LYRDCodeGenerate = '',
  })
end

function L.keybindings(s)

  mappings.space_menu(s, {
    {{'g'}, 'Git Repository'},
    {{'g', 'f'}, 'Gitflow'},
    {{'a'}, 'Application'},
    {{'b'}, 'Buffers'},
    {{'c'}, 'Code'},
    {{'t'}, 'Test'},
    {{'d'}, 'Debug'},
    {{'p'}, 'Plugins'},
    {{'q'}, 'Quit'},
    {{'s'}, 'Search'},
    {{'u'}, 'User interface'},
    {{'v'}, 'View'}
  })
  mappings.space(s, {
    {'n', {'<Tab>'}, c('LYRDBufferJumpToLast'), 'Jump to last buffer'},
    -- View Menu
    {'n', {'v', '.'}, c('LYRDViewHomePage'), 'Home page'},
    {'n', {'v', 't'}, c('LYRDViewFileTree'), 'Toggle file tree'},
    {'n', {'v', 'e'}, c('LYRDViewFileExplorer'), 'Explore files'},
    {'n', {'v', 'l'}, c('LYRDViewLocationList'), 'Location list'},
    {'n', {'v', 'r'}, c('LYRDViewRegisters'), 'Registers'},
    {'n', {'v', 'y'}, c('LYRDViewYankList'), 'Yank list'},
    {'n', {'v', 'q'}, c('LYRDViewQuickFixList'), 'QuickFix'},
    {'n', {'v', 'd'}, c('LYRDLSPShowDocumentDiagnosticLocList'), 'Document diagnostics'},
    {'n', {'v', 'D'}, c('LYRDLSPShowWorkspaceDiagnosticLocList'), 'Workspace diagnostics'},
    -- Buffer Menu
    {'n', {'b', 'e'}, c('LYRDBufferNew'), 'New empty buffer'},
    {'n', {'b', 'n'}, c('LYRDBufferNext'), 'Next buffer'},
    {'n', {'b', 'p'}, c('LYRDBufferPrev'), 'Previous buffer'},
    {'n', {'b', 'd'}, c('LYRDBufferClose'), 'Close buffer'},
    {'n', {'b', 'D'}, c('LYRDBufferForceClose'), 'Force close buffer'},
    {'n', {'b', 'f'}, c('LYRDBufferFormat'), 'Format document'},
    {'n', {'b', 'x'}, c('LYRDBufferCloseAll'), 'Close all buffers'},
    {'n', {'b', 'X'}, c('LYRDBufferForceCloseAll'), 'Force close all buffers'},
    {'n', {'b', 'h'}, c('LYRDBufferSplitH'), 'Horizonal split'},
    {'n', {'b', 'v'}, c('LYRDBufferSplitV'), 'Vertical split'},
    {'n', {'b', 'w'}, c('LYRDBufferSetReadOnly'), 'Toggle read only mode'},
    {'n', {'b', 'Y'}, c('LYRDBufferCopy'), 'Copy whole buffer to clipboard'},
    {'n', {'b', 'P'}, c('LYRDBufferPaste'), 'Paste clipboard to whole buffer'},
    {'n', {'b', '/'}, c('LYRDSearchBuffers'), 'Buffer list'},
    {'n', {'b', 's'}, c('LYRDBufferSave'), 'Save current file'},
    {'n', {'b', 'S'}, c('LYRDBufferSaveAll'), 'Save all files'},
    -- Application Menu
    {'n', {'a', 'i'}, c('LYRDPluginsInstall'), 'Install plugins'},
    {'n', {'a', 'u'}, c('LYRDPluginsUpdate'), 'Update plugins'},
    {'n', {'a', 'c'}, c('LYRDPluginsClean'), 'Clean plugins'},
    {'n', {'a', 't'}, c('LYRDTerminal'), 'Terminal'},
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
    {'n', {'g', 's'}, c('LYRDGitStatus'), 'Status'},
    {'n', {'g', 'S'}, c('LYRDGitStageCurrentFile'), 'Stage current file'},
    {'n', {'g', 'U'}, c('LYRDGitUnstageCurrentFile'), 'Unstage current file'},
    {'n', {'g', 'c'}, c('LYRDGitCommit'), 'Commit changes'},
    {'n', {'g', 'a'}, c('LYRDGitWrite'), 'Write'},
    {'n', {'g', 'p'}, c('LYRDGitPush'), 'Push'},
    {'n', {'g', 'P'}, c('LYRDGitPull'), 'Pull'},
    {'n', {'g', 'd'}, c('LYRDGitViewDiff'), 'View diff'},
    {'n', {'g', 'A'}, c('LYRDGitStageAll'), 'Stage all'},
    {'n', {'g', 'b'}, c('LYRDGitViewBlame'), 'View blame'},
    {'n', {'g', 'r'}, c('LYRDGitRemove'), 'Remove'},
    {'n', {'g', 'V'}, c('LYRDGitViewCurrentFileLog'), 'Current file log'},
    {'n', {'g', 'v'}, c('LYRDGitViewLog'), 'File log'},
    {'n', {'g', 'o'}, c('LYRDGitBrowseOnWeb'), 'Browse line on web'},
    {'n', {'g', 'f', 'i'}, c('LYRDGitFlowInit'), 'Init'},
    {'n', {'g', 'f', 'f'}, c('LYRDGitFlowFeatureStart'), 'Feature start'},
    {'n', {'g', 'f', 'F'}, c('LYRDGitFlowFeatureFinish'), 'Feature finish'},
    {'n', {'g', 'f', 'r'}, c('LYRDGitFlowReleaseStart'), 'Release start'},
    {'n', {'g', 'f', 'R'}, c('LYRDGitFlowReleaseFinish'), 'Release finish'},
    {'n', {'g', 'f', 'h'}, c('LYRDGitFlowHotfixStart'), 'Hotfix start'},
    {'n', {'g', 'f', 'H'}, c('LYRDGitFlowHotfixFinish'), 'Hotfix finish'},
    {'n', {'g', 'f', 'D'}, c('LYRDGitCheckoutDev'), 'Checkout Develop branch'},
    {'n', {'g', 'f', 'M'}, c('LYRDGitCheckoutMain'), 'Checkout Main branch'},
    -- Code Menu
    {'n', {'c', 'a'}, c('LYRDLSPFindCodeActions'), 'Actions'},
    {'n', {'c', 'A'}, c('LYRDLSPFindRangeCodeActions'), 'Range Actions'},
    {'n', {'c', 'b'}, c('LYRDCodeBuild'), 'Build'},
    {'n', {'c', 'r'}, c('LYRDCodeRun'), 'Run'},
    {'n', {'c', 'a'}, c('LYRDCodeAlternateFile'), 'Toggle alternate file'},
    {'n', {'c', 'i'}, c('LYRDCodeFixImports'), 'Fix imports'},
    {'n', {'c', 'c'}, c('LYRDCodeGlobalCheck'), 'Global check'},
    {'n', {'c', 'I'}, c('LYRDCodeImplementInterface'), 'Implement interface'},
    {'n', {'c', 's'}, c('LYRDCodeFillStructure'), 'Fill structure'},
    {'n', {'c', 's'}, c('LYRDCodeInsertSnippet'), 'Insert snippet'},
    {'n', {'c', 'g'}, c('LYRDCodeGenerate'), 'Generate Code'},
    -- Test menu
    {'n', {'t', 't'}, c('LYRDTest'), 'Test everything'},
    {'n', {'t', 's'}, c('LYRDTestSuite'), 'Test suite'},
    {'n', {'t', 'F'}, c('LYRDTestFile'), 'Test current file'},
    {'n', {'t', 'f'}, c('LYRDTestFunc'), 'Test current function'},
    {'n', {'t', 'l'}, c('LYRDTestLast'), 'Repeat last test'},
    {'n', {'t', 'c'}, c('LYRDTestCoverage'), 'Test Coverage'}
  })
end

return L
