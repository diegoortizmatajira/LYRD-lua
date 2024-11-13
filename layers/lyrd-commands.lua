local commands = require("LYRD.layers.commands")

local L = {
	name = "LYRD Commands",
	cmd = {
		LYRDAIAssistant = { desc = "Open AI Assistant", icon = "󱜙" },
		LYRDAIRefactor = { desc = "Open AI Refactor", icon = "" },
		LYRDAISuggestions = { desc = "Open AI Suggestions" },
		LYRDBreakLine = { default = ":s/[,(]/&\r/ge|:noh|:'[,']normal==", desc = "Break current line" },
		LYRDBufferClose = { default = ":bd", desc = "Close buffer", icon = "" },
		LYRDBufferCloseAll = { default = ":bufdo bd", desc = "Close all buffers", icon = "" },
		LYRDBufferCopy = { default = ':normal! ggVG"+y``', desc = "Copy whole buffer to clipboard" },
		LYRDBufferForceClose = { default = ":bd!", desc = "Force close buffer", icon = "x" },
		LYRDBufferForceCloseAll = { default = ":bufdo bd!", desc = "Force close all buffers" },
		LYRDBufferFormat = { desc = "Format document" },
		LYRDBufferJumpToLast = { default = ":b#", desc = "Jump to last buffer" },
		LYRDBufferNew = { default = ":enew", desc = "New empty buffer" },
		LYRDBufferNext = { default = ":bn", desc = "Next buffer" },
		LYRDBufferPaste = { default = ':normal! ggdG"+P', desc = "Paste clipboard to whole buffer" },
		LYRDBufferPrev = { default = ":bp", desc = "Previous Buffer" },
		LYRDBufferSave = { default = ":w", desc = "Save current file" },
		LYRDBufferSaveAll = { default = ":wall", desc = "Save all files" },
		LYRDBufferSetReadOnly = { default = ":setl readonly!", desc = "Toggle read only mode" },
		LYRDBufferSplitH = { default = ":split", desc = "Horizonal split" },
		LYRDBufferSplitV = { default = ":vsplit", desc = "Vertical split" },
		LYRDBufferToggleWrap = { default = ":setlocal wrap!", desc = "Toggle line wrap" },
		LYRDCodeAlternateFile = { desc = "Toggle alternate file" },
		LYRDCodeBuild = { desc = "Build" },
		LYRDCodeFillStructure = { desc = "Fill structure" },
		LYRDCodeFixImports = { desc = "Fix imports" },
		LYRDCodeGenerate = { desc = "Run Generator Tool" },
		LYRDCodeGlobalCheck = { desc = "Global check" },
		LYRDCodeImplementInterface = { desc = "Implement interface" },
		LYRDCodeInsertSnippet = { desc = "Insert snippet" },
		LYRDCodeProduceGetter = { desc = "Generate getters code" },
		LYRDCodeProduceMapping = { desc = "Generate mappings code" },
		LYRDCodeProduceSetter = { desc = "Generate setters code" },
		LYRDCodeRefactor = { desc = "Refactor" },
		LYRDCodeRun = { desc = "Run" },
		LYRDDebugBreakpoint = { desc = "Toggle breakpoint" },
		LYRDDebugContinue = { desc = "Start / Continue" },
		LYRDDebugStepInto = { desc = "Step into" },
		LYRDDebugStepOver = { desc = "Step over" },
		LYRDDebugStop = { desc = "Stop" },
		LYRDDebugToggleRepl = { desc = "Toggle Debug Repl" },
		LYRDDebugToggleUI = { desc = "Toggle Debug UI" },
		LYRDDiagnosticLinesToggle = { desc = "Toggle diagnostic lines" },
		LYRDGitUI = { desc = "Git UI" },
		LYRDGitBrowseOnWeb = { desc = "Browse line on web" },
		LYRDGitCheckoutDev = { desc = "Checkout Develop branch" },
		LYRDGitCheckoutMain = { desc = "Checkout Main branch" },
		LYRDGitCommit = { desc = "Commit changes" },
		LYRDGitFlowFeatureFinish = { desc = "Feature finish" },
		LYRDGitFlowFeatureStart = { desc = "Feature start" },
		LYRDGitFlowHotfixFinish = { desc = "Hotfix finish" },
		LYRDGitFlowHotfixStart = { desc = "Hotfix start" },
		LYRDGitFlowInit = { desc = "Init" },
		LYRDGitFlowReleaseFinish = { desc = "Release finish" },
		LYRDGitFlowReleaseStart = { desc = "Release start" },
		LYRDGitPull = { desc = "Pull" },
		LYRDGitPush = { desc = "Push" },
		LYRDGitStageAll = { desc = "Stage all" },
		LYRDGitStatus = { desc = "Status" },
		LYRDGitViewBlame = { desc = "View blame" },
		LYRDGitViewCurrentFileLog = { desc = "Current file log" },
		LYRDGitViewDiff = { desc = "View diff" },
		LYRDGitViewLog = { desc = "File log" },
		LYRDGitWrite = { desc = "Write" },
		LYRDImplementedCommands = { default = commands.list_implemented, desc = "List implemented commands" },
		LYRDLSPFindCodeActions = { desc = "Actions" },
		LYRDLSPFindDeclaration = { desc = "" },
		LYRDLSPFindDefinitions = { desc = "" },
		LYRDLSPFindDocumentDiagnostics = { desc = "" },
		LYRDLSPFindDocumentSymbols = { desc = "" },
		LYRDLSPFindImplementations = { desc = "" },
		LYRDLSPFindLineDiagnostics = { desc = "" },
		LYRDLSPFindRangeCodeActions = { desc = "Range Actions" },
		LYRDLSPFindReferences = { desc = "" },
		LYRDLSPFindTypeDefinition = { desc = "" },
		LYRDLSPFindWorkspaceDiagnostics = { desc = "" },
		LYRDLSPFindWorkspaceSymbols = { desc = "" },
		LYRDLSPGotoNextDiagnostic = { desc = "" },
		LYRDLSPGotoPrevDiagnostic = { desc = "" },
		LYRDLSPHoverInfo = { desc = "" },
		LYRDLSPRename = { desc = "Rename symbol" },
		LYRDLSPShowDocumentDiagnosticLocList = { desc = "Document diagnostics" },
		LYRDLSPShowWorkspaceDiagnosticLocList = { desc = "Workspace diagnostics" },
		LYRDLSPSignatureHelp = { desc = "" },
		LYRDPluginsClean = { default = ":Lazy clean", desc = "Clean plugins" },
		LYRDPluginsInstall = { default = ":Lazy install", desc = "Install plugins" },
		LYRDPluginsUpdate = { default = ":Lazy sync", desc = "Update plugins" },
		LYRDSearchBufferLines = { desc = "Lines" },
		LYRDSearchBufferTags = { desc = "Tags" },
		LYRDSearchBuffers = { desc = "Search buffers" },
		LYRDSearchColorSchemes = { desc = "Color Schemes" },
		LYRDSearchCommandHistory = { desc = "Recent comands" },
		LYRDSearchCommands = { desc = "Commands" },
		LYRDSearchCurrentString = { desc = "Current string in files" },
		LYRDSearchFiles = { desc = "Find files" },
		LYRDSearchFiletypes = { desc = "Filetypes" },
		LYRDSearchGitFiles = { desc = "Git Files" },
		LYRDSearchHighlights = { desc = "Highlights" },
		LYRDSearchKeyMappings = { desc = "Key Maps" },
		LYRDSearchLiveGrep = { desc = "Live grep" },
		LYRDSearchQuickFixes = { desc = "Quick Fixes" },
		LYRDSearchRecentFiles = { desc = "Recent files" },
		LYRDSearchRegisters = { desc = "Registers" },
		LYRDResumeLastSearch = { desc = "Resume last search" },
		LYRDSmartCoder = { desc = "Smart code generator" },
		LYRDTerminal = { default = ":terminal", desc = "Terminal" },
		LYRDTest = { desc = "Test everything" },
		LYRDTestCoverage = { desc = "Test Coverage" },
		LYRDTestFile = { desc = "Test current file" },
		LYRDTestFunc = { desc = "Test current function" },
		LYRDTestLast = { desc = "Repeat last test" },
		LYRDTestSuite = { desc = "Test suite" },
		LYRDTestSummary = { desc = "View test summary" },
		LYRDUnimplementedCommands = { default = commands.list_unimplemented, desc = "List unimplemented commands" },
		LYRDViewFileExplorer = { desc = "File Explorer" },
		LYRDViewFileTree = { desc = "Toggle file tree" },
		LYRDViewHomePage = { desc = "Home page" },
		LYRDViewLocationList = { desc = "Location list" },
		LYRDViewQuickFixList = { default = ":cope", desc = "QuickFix" },
		LYRDViewRegisters = { desc = "Registers" },
		LYRDViewYankList = { desc = "Yank list" },
		LYRDWindowClose = { default = ":q", desc = "Close window" },
		LYRDWindowCloseAll = { default = ":qa", desc = "Close all" },
		LYRDWindowForceCloseAll = { default = ":qa!", desc = "Force Quit" },
		LYRDPaneNavigateLeft = { default = "<C-w>h", desc = "Navigate to panel left" },
		LYRDPaneNavigateDown = { default = "<C-w>j", desc = "Navigate to panel below" },
		LYRDPaneNavigateUp = { default = "<C-w>k", desc = "Navigate to panel up" },
		LYRDPaneNavigateRight = { default = "<C-w>l", desc = "Navigate to panel right" },
		LYRDPaneResizeLeft = { desc = "Resize to panel left" },
		LYRDPaneResizeDown = { desc = "Resize to panel below" },
		LYRDPaneResizeUp = { desc = "Resize to panel up" },
		LYRDPaneResizeRight = { desc = "Resize to panel right" },
		LYRDPaneSwapLeft = { desc = "Swap to panel left" },
		LYRDPaneSwapDown = { desc = "Swap to panel below" },
		LYRDPaneSwapUp = { desc = "Swap to panel up" },
		LYRDPaneSwapRight = { desc = "Swap to panel right" },
		LYRDDatabaseUI = { desc = "Database UI" },
		LYRDContainersUI = { desc = "Running containers UI" },
		LYRDKubernetesUI = { desc = "Kubernetes UI" },
		LYRDScratchNew = { desc = "Create a new scratch" },
		LYRDScratchOpen = { desc = "Select scratch file to open" },
		LYRDScratchSearch = { desc = "Search inside scratches" },
	},
}

function L.settings(s)
	commands.register(s, L.cmd)
end

return L
