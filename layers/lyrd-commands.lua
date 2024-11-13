local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")

local L = {
	name = "LYRD Commands",
	cmd = {
		LYRDAIAssistant = {
			desc = "Open AI Assistant",
			icon = icons.other.ia,
		},
		LYRDAIRefactor = {
			desc = "Open AI Refactor",
			icon = icons.other.wrench,
		},
		LYRDAISuggestions = {
			desc = "Open AI Suggestions",
			icon = icons.other.ia,
		},
		LYRDBreakLine = {
			default = ":s/[,(]/&\r/ge|:noh|:'[,']normal==",
			desc = "Break current line",
			icon = icons.action.break_line,
		},
		LYRDBufferClose = {
			default = ":bd",
			desc = "Close buffer",
			icon = icons.action.close,
		},
		LYRDBufferCloseAll = {
			default = ":bufdo bd",
			desc = "Close all buffers",
			icon = icons.action.close_many,
		},
		LYRDBufferCopy = {
			default = ':normal! ggVG"+y``',
			desc = "Copy whole buffer to clipboard",
			icon = icons.action.copy,
		},
		LYRDBufferForceClose = {
			default = ":bd!",
			desc = "Force close buffer",
			icon = icons.action.kill,
		},
		LYRDBufferForceCloseAll = {
			default = ":bufdo bd!",
			desc = "Force close all buffers",
			icon = icons.action.kill_target,
		},
		LYRDBufferFormat = {
			desc = "Format document",
			icon = icons.action.format,
		},
		LYRDBufferJumpToLast = {
			default = ":b#",
			desc = "Jump to last buffer",
			icon = icons.arrow.up_left,
		},
		LYRDBufferNew = {
			default = ":enew",
			desc = "New empty buffer",
			icon = icons.file.new,
		},
		LYRDBufferNext = {
			default = ":bn",
			desc = "Next buffer",
			icon = icons.chevron.double_right,
		},
		LYRDBufferPaste = {
			default = ':normal! ggdG"+P',
			desc = "Paste clipboard to whole buffer",
			icon = icons.action.paste,
		},
		LYRDBufferPrev = {
			default = ":bp",
			desc = "Previous Buffer",
			icon = icons.chevron.double_left,
		},
		LYRDBufferSave = {
			default = ":w",
			desc = "Save current file",
			icon = icons.action.save,
		},
		LYRDBufferSaveAll = {
			default = ":wall",
			desc = "Save all files",
			icon = icons.action.save_all,
		},
		LYRDBufferSetReadOnly = {
			default = ":setl readonly!",
			desc = "Toggle read only mode",
			icon = icons.action.toggle_on,
		},
		LYRDBufferSplitH = {
			default = ":split",
			desc = "Horizonal split",
			icon = icons.action.split_h,
		},
		LYRDBufferSplitV = {
			default = ":vsplit",
			desc = "Vertical split",
			icon = icons.action.split_v,
		},
		LYRDBufferToggleWrap = {
			default = ":setlocal wrap!",
			desc = "Toggle line wrap",
			icon = icons.action.wrap,
		},
		LYRDCodeAlternateFile = {
			desc = "Toggle alternate file",
			icon = icons.file.swap,
		},
		LYRDCodeBuild = {
			desc = "Build",
			icon = icons.code.build,
		},
		LYRDCodeFillStructure = {
			desc = "Fill structure",
			icon = icons.code.outline,
		},
		LYRDCodeFixImports = {
			desc = "Fix imports",
			icon = icons.code.fix,
		},
		LYRDCodeGenerate = {
			desc = "Run Generator Tool",
			icon = icons.code.generate,
		},
		LYRDCodeGlobalCheck = {
			desc = "Global check",
			icon = icons.code.check,
		},
		LYRDCodeImplementInterface = {
			desc = "Implement interface",
			icon = icons.code.interface,
		},
		LYRDCodeInsertSnippet = {
			desc = "Insert snippet",
			icon = icons.code.snippet,
		},
		LYRDCodeProduceGetter = {
			desc = "Generate getters code",
			icon = icons.code.generate,
		},
		LYRDCodeProduceMapping = {
			desc = "Generate mappings code",
			icon = icons.code.generate,
		},
		LYRDCodeProduceSetter = {
			desc = "Generate setters code",
			icon = icons.code.generate,
		},
		LYRDCodeRefactor = {
			desc = "Refactor",
			icon = icons.code.refactor,
		},
		LYRDCodeRun = {
			desc = "Run",
			icon = icons.code.run,
		},
		LYRDDebugBreakpoint = {
			desc = "Toggle breakpoint",
			icon = icons.debug.breakpoint,
		},
		LYRDDebugContinue = {
			desc = "Start / Continue",
			icon = icons.debug.play,
		},
		LYRDDebugStepInto = {
			desc = "Step into",
			icon = icons.debug.step_into,
		},
		LYRDDebugStepOver = {
			desc = "Step over",
			icon = icons.debug.step_over,
		},
		LYRDDebugStop = {
			desc = "Stop",
			icon = icons.debug.terminate,
		},
		LYRDDebugToggleRepl = {
			desc = "Toggle Debug Repl",
			icon = icons.action.toggle_on,
		},
		LYRDDebugToggleUI = {
			desc = "Toggle Debug UI",
			icon = icons.action.toggle_on,
		},
		LYRDDiagnosticLinesToggle = {
			desc = "Toggle diagnostic lines",
			icon = icons.action.toggle_on,
		},
		LYRDGitUI = {
			desc = "Git UI",
			icon = icons.apps.git,
		},
		LYRDGitBrowseOnWeb = {
			desc = "Browse line on web",
			icon = icons.apps.browser,
		},
		LYRDGitCheckoutDev = {
			desc = "Checkout Develop branch",
			icon = icons.git.branch,
		},
		LYRDGitCheckoutMain = {
			desc = "Checkout Main branch",
			icon = icons.git.branch,
		},
		LYRDGitCommit = {
			desc = "Commit changes",
			icon = icons.git.commit,
		},
		LYRDGitFlowFeatureFinish = {
			desc = "Feature finish",
			icon = icons.git.commit_end,
		},
		LYRDGitFlowFeatureStart = {
			desc = "Feature start",
			icon = icons.git.commit_start,
		},
		LYRDGitFlowHotfixFinish = {
			desc = "Hotfix finish",
			icon = icons.git.commit_end,
		},
		LYRDGitFlowHotfixStart = {
			desc = "Hotfix start",
			icon = icons.git.commit_start,
		},
		LYRDGitFlowInit = {
			desc = "Init",
			icon = icons.git.init,
		},
		LYRDGitFlowReleaseFinish = {
			desc = "Release finish",
			icon = icons.git.commit_end,
		},
		LYRDGitFlowReleaseStart = {
			desc = "Release start",
			icon = icons.git.commit_start,
		},
		LYRDGitPull = {
			desc = "Pull",
			icon = icons.git.pull,
		},
		LYRDGitPush = {
			desc = "Push",
			icon = icons.git.push,
		},
		LYRDGitStageAll = {
			desc = "Stage all",
			icon = icons.git.stage_all,
		},
		LYRDGitStatus = {
			desc = "Status",
			icon = icons.git.status,
		},
		LYRDGitViewBlame = {
			desc = "View blame",
			icon = icons.git.blame,
		},
		LYRDGitViewCurrentFileLog = {
			desc = "Current file log",
			icon = icons.git.log,
		},
		LYRDGitViewDiff = {
			desc = "View diff",
			icon = icons.git.diff,
		},
		LYRDGitViewLog = {
			desc = "File log",
			icon = icons.git.log,
		},
		LYRDGitWrite = {
			desc = "Write",
		},
		LYRDImplementedCommands = {
			default = commands.list_implemented,
			desc = "List implemented commands",
		},
		LYRDLSPFindCodeActions = {
			desc = "Actions",
			icon = icons.action.code_action,
		},
		LYRDLSPFindDeclaration = {
			desc = "",
		},
		LYRDLSPFindDefinitions = {
			desc = "",
		},
		LYRDLSPFindDocumentDiagnostics = {
			desc = "",
		},
		LYRDLSPFindDocumentSymbols = {
			desc = "",
		},
		LYRDLSPFindImplementations = {
			desc = "",
		},
		LYRDLSPFindLineDiagnostics = {
			desc = "",
		},
		LYRDLSPFindRangeCodeActions = {
			desc = "Range Actions",
		},
		LYRDLSPFindReferences = {
			desc = "",
		},
		LYRDLSPFindTypeDefinition = {
			desc = "",
		},
		LYRDLSPFindWorkspaceDiagnostics = {
			desc = "",
		},
		LYRDLSPFindWorkspaceSymbols = {
			desc = "",
		},
		LYRDLSPGotoNextDiagnostic = {
			desc = "",
		},
		LYRDLSPGotoPrevDiagnostic = {
			desc = "",
		},
		LYRDLSPHoverInfo = {
			desc = "",
		},
		LYRDLSPRename = {
			desc = "Rename symbol",
		},
		LYRDLSPShowDocumentDiagnosticLocList = {
			desc = "Document diagnostics",
		},
		LYRDLSPShowWorkspaceDiagnosticLocList = {
			desc = "Workspace diagnostics",
		},
		LYRDLSPSignatureHelp = {
			desc = "",
		},
		LYRDPluginsClean = {
			default = ":Lazy clean",
			desc = "Clean plugins",
		},
		LYRDPluginsInstall = {
			default = ":Lazy install",
			desc = "Install plugins",
		},
		LYRDPluginsUpdate = {
			default = ":Lazy sync",
			desc = "Update plugins",
		},
		LYRDSearchBufferLines = {
			desc = "Lines",
		},
		LYRDSearchBufferTags = {
			desc = "Tags",
		},
		LYRDSearchBuffers = {
			desc = "Search buffers",
		},
		LYRDSearchColorSchemes = {
			desc = "Color Schemes",
		},
		LYRDSearchCommandHistory = {
			desc = "Recent comands",
		},
		LYRDSearchCommands = {
			desc = "Commands",
		},
		LYRDSearchCurrentString = {
			desc = "Current string in files",
		},
		LYRDSearchFiles = {
			desc = "Find files",
		},
		LYRDSearchFiletypes = {
			desc = "Filetypes",
		},
		LYRDSearchGitFiles = {
			desc = "Git Files",
		},
		LYRDSearchHighlights = {
			desc = "Highlights",
		},
		LYRDSearchKeyMappings = {
			desc = "Key Maps",
		},
		LYRDSearchLiveGrep = {
			desc = "Live grep",
		},
		LYRDSearchQuickFixes = {
			desc = "Quick Fixes",
		},
		LYRDSearchRecentFiles = {
			desc = "Recent files",
		},
		LYRDSearchRegisters = {
			desc = "Registers",
		},
		LYRDResumeLastSearch = {
			desc = "Resume last search",
		},
		LYRDSmartCoder = {
			desc = "Smart code generator",
		},
		LYRDTerminal = {
			default = ":terminal",
			desc = "Terminal",
		},
		LYRDTest = {
			desc = "Test everything",
		},
		LYRDTestCoverage = {
			desc = "Test Coverage",
		},
		LYRDTestFile = {
			desc = "Test current file",
		},
		LYRDTestFunc = {
			desc = "Test current function",
		},
		LYRDTestLast = {
			desc = "Repeat last test",
		},
		LYRDTestSuite = {
			desc = "Test suite",
		},
		LYRDTestSummary = {
			desc = "View test summary",
		},
		LYRDUnimplementedCommands = {
			default = commands.list_unimplemented,
			desc = "List unimplemented commands",
		},
		LYRDViewFileExplorer = {
			desc = "File Explorer",
		},
		LYRDViewFileTree = {
			desc = "Toggle file tree",
		},
		LYRDViewHomePage = {
			desc = "Home page",
			icon = icons.other.home,
		},
		LYRDViewLocationList = {
			desc = "Location list",
		},
		LYRDViewQuickFixList = {
			default = ":cope",
			desc = "QuickFix",
		},
		LYRDViewRegisters = {
			desc = "Registers",
		},
		LYRDViewYankList = {
			desc = "Yank list",
		},
		LYRDWindowClose = {
			default = ":q",
			desc = "Close window",
		},
		LYRDWindowCloseAll = {
			default = ":qa",
			desc = "Close all",
		},
		LYRDWindowForceCloseAll = {
			default = ":qa!",
			desc = "Force Quit",
		},
		LYRDPaneNavigateLeft = {
			default = "<C-w>h",
			desc = "Navigate to panel left",
		},
		LYRDPaneNavigateDown = {
			default = "<C-w>j",
			desc = "Navigate to panel below",
		},
		LYRDPaneNavigateUp = {
			default = "<C-w>k",
			desc = "Navigate to panel up",
		},
		LYRDPaneNavigateRight = {
			default = "<C-w>l",
			desc = "Navigate to panel right",
		},
		LYRDPaneResizeLeft = {
			desc = "Resize to panel left",
		},
		LYRDPaneResizeDown = {
			desc = "Resize to panel below",
		},
		LYRDPaneResizeUp = {
			desc = "Resize to panel up",
		},
		LYRDPaneResizeRight = {
			desc = "Resize to panel right",
		},
		LYRDPaneSwapLeft = {
			desc = "Swap to panel left",
		},
		LYRDPaneSwapDown = {
			desc = "Swap to panel below",
		},
		LYRDPaneSwapUp = {
			desc = "Swap to panel up",
		},
		LYRDPaneSwapRight = {
			desc = "Swap to panel right",
		},
		LYRDDatabaseUI = {
			desc = "Database UI",
		},
		LYRDContainersUI = {
			desc = "Running containers UI",
		},
		LYRDKubernetesUI = {
			desc = "Kubernetes UI",
		},
		LYRDScratchNew = {
			desc = "Create a new scratch",
		},
		LYRDScratchOpen = {
			desc = "Select scratch file to open",
		},
		LYRDScratchSearch = {
			desc = "Search inside scratches",
		},
	},
}

function L.settings(s)
	commands.register(s, L.cmd)
end

return L
