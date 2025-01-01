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
		LYRDCodeMakeTasks = {
			desc = "Make tasks",
			icon = icons.code.make,
		},
		LYRDCodeBuild = {
			desc = "Build",
			icon = icons.code.build,
		},
		LYRDCodeBuildAll = {
			desc = "Build all",
			icon = icons.code.build,
		},
		LYRDCodeAddDocumentation = {
			desc = "Add documentation",
			icon = icons.code.document,
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
		LYRDCodeRestorePackages = {
			desc = "Restore packages",
			icon = icons.code.package,
		},
		LYRDCodeRefactor = {
			desc = "Refactor",
			icon = icons.code.refactor,
		},
		LYRDCodeRun = {
			desc = "Run",
			icon = icons.code.run,
		},
		LYRDCodeSelectEnvironment = {
			desc = "Select environment",
			icon = icons.other.environment,
		},
		LYRDCodeSecrets = {
			desc = "Edit Secrets",
			icon = icons.other.secret,
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
		LYRDLSPToggleLens = {
			desc = "Toggle Code Lens",
			icon = icons.action.toggle_on,
		},
		LYRDLSPFindCodeActions = {
			desc = "Actions",
			icon = icons.action.code_action,
		},
		LYRDLSPFindDeclaration = {
			desc = "",
			icon = icons.code.navigate,
		},
		LYRDLSPFindDefinitions = {
			desc = "",
			icon = icons.code.navigate,
		},
		LYRDLSPFindDocumentDiagnostics = {
			desc = "",
			icon = icons.diagnostic.search,
		},
		LYRDLSPFindDocumentSymbols = {
			desc = "",
			icon = icons.code.symbol,
		},
		LYRDLSPFindImplementations = {
			desc = "",
			icon = icons.code.navigate,
		},
		LYRDLSPFindLineDiagnostics = {
			desc = "",
			icon = icons.diagnostic.search,
		},
		LYRDLSPFindRangeCodeActions = {
			desc = "Range Actions",
			icon = icons.action.code_action,
		},
		LYRDLSPFindReferences = {
			desc = "",
			icon = icons.code.navigate,
		},
		LYRDLSPFindTypeDefinition = {
			desc = "",
			icon = icons.code.navigate,
		},
		LYRDLSPFindWorkspaceDiagnostics = {
			desc = "",
			icon = icons.diagnostic.search,
		},
		LYRDLSPFindWorkspaceSymbols = {
			desc = "",
			icon = icons.code.symbol,
		},
		LYRDLSPGotoNextDiagnostic = {
			desc = "",
			icon = icons.diagnostic.next,
		},
		LYRDLSPGotoPrevDiagnostic = {
			desc = "",
			icon = icons.diagnostic.prev,
		},
		LYRDLSPHoverInfo = {
			desc = "",
			icon = icons.code.hint,
		},
		LYRDLSPRename = {
			desc = "Rename symbol",
			icon = icons.code.rename,
		},
		LYRDLSPShowDocumentDiagnosticLocList = {
			desc = "Document diagnostics",
			icon = icons.diagnostic.search,
		},
		LYRDLSPShowWorkspaceDiagnosticLocList = {
			desc = "Workspace diagnostics",
			icon = icons.diagnostic.search,
		},
		LYRDLSPSignatureHelp = {
			desc = "Signature help",
			icon = icons.code.hint,
		},
		LYRDToolManager = {
			desc = "Tool Manager",
			icon = icons.other.tools,
		},
		LYRDPluginManager = {
			default = ":Lazy",
			desc = "Plugin Manager",
			icon = icons.other.plug,
		},
		LYRDPluginsClean = {
			default = ":Lazy clean",
			desc = "Clean plugins",
			icon = icons.action.clean,
		},
		LYRDPluginsInstall = {
			default = ":Lazy install",
			desc = "Install plugins",
			icon = icons.action.install,
		},
		LYRDPluginsUpdate = {
			default = ":Lazy sync",
			desc = "Update plugins",
			icon = icons.action.update,
		},
		LYRDSearchBufferLines = {
			desc = "Lines",
			icon = icons.search.lines,
		},
		LYRDSearchBufferTags = {
			desc = "Tags",
			icon = icons.search.tags,
		},
		LYRDSearchBuffers = {
			desc = "Search buffers",
			icon = icons.search.buffers,
		},
		LYRDSearchColorSchemes = {
			desc = "Color Schemes",
			icon = icons.search.default,
		},
		LYRDSearchCommandHistory = {
			desc = "Recent comands",
			icon = icons.search.history,
		},
		LYRDSearchCommands = {
			desc = "Commands",
			icon = icons.search.commands,
		},
		LYRDSearchCurrentString = {
			desc = "Current string in files",
			icon = icons.search.default,
		},
		LYRDSearchFiles = {
			desc = "Find files",
			icon = icons.search.files,
		},
		LYRDSearchFiletypes = {
			desc = "Filetypes",
			icon = icons.search.default,
		},
		LYRDSearchGitFiles = {
			desc = "Git Files",
			icon = icons.search.files,
		},
		LYRDSearchHighlights = {
			desc = "Highlights",
			icon = icons.search.default,
		},
		LYRDSearchKeyMappings = {
			desc = "Key Maps",
			icon = icons.search.keys,
		},
		LYRDSearchLiveGrep = {
			desc = "Live grep",
			icon = icons.search.default,
		},
		LYRDSearchQuickFixes = {
			desc = "Quick Fixes",
			icon = icons.diagnostic.search,
		},
		LYRDSearchRecentFiles = {
			desc = "Recent files",
			icon = icons.search.history,
		},
		LYRDSearchRegisters = {
			desc = "Registers",
			icon = icons.search.default,
		},
		LYRDResumeLastSearch = {
			desc = "Resume last search",
			icon = icons.search.history,
		},
		LYRDSmartCoder = {
			desc = "Smart code generator",
			icon = icons.code.generate,
		},
		LYRDTerminalList = {
			desc = "View terminal list",
			icon = icons.search.layers,
		},
		LYRDTerminal = {
			default = ":terminal",
			desc = "Terminal",
			icon = icons.apps.terminal,
		},
		LYRDTest = {
			desc = "Test everything",
			icon = icons.code.test,
		},
		LYRDTestCoverageSummary = {
			desc = "View Test Coverage Summary",
			icon = icons.code.test,
		},
		LYRDTestCoverage = {
			desc = "Toggle Test Coverage",
			icon = icons.code.test,
		},
		LYRDTestFile = {
			desc = "Test current file",
			icon = icons.code.test,
		},
		LYRDTestFunc = {
			desc = "Test current function",
			icon = icons.code.test,
		},
		LYRDTestLast = {
			desc = "Repeat last test",
			icon = icons.action.repeat_once,
		},
		LYRDTestSuite = {
			desc = "Test suite",
			icon = icons.code.test,
		},
		LYRDTestSummary = {
			desc = "View test summary",
			icon = icons.other.report,
		},
		LYRDUnimplementedCommands = {
			default = commands.list_unimplemented,
			desc = "List unimplemented commands",
			icon = icons.search.commands,
		},
		LYRDViewFileExplorer = {
			desc = "File Explorer",
			icon = icons.apps.file_explorer,
		},
		LYRDViewFileTree = {
			desc = "Toggle file tree",
			icon = icons.action.toggle_on,
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
			icon = icons.arrow.left,
		},
		LYRDPaneNavigateDown = {
			default = "<C-w>j",
			desc = "Navigate to panel below",
			icon = icons.arrow.down,
		},
		LYRDPaneNavigateUp = {
			default = "<C-w>k",
			desc = "Navigate to panel up",
			icon = icons.arrow.up,
		},
		LYRDPaneNavigateRight = {
			default = "<C-w>l",
			desc = "Navigate to panel right",
			icon = icons.arrow.right,
		},
		LYRDPaneResizeLeft = {
			desc = "Resize to panel left",
			icon = icons.arrow.collapse_left,
		},
		LYRDPaneResizeDown = {
			desc = "Resize to panel below",
			icon = icons.arrow.collapse_down,
		},
		LYRDPaneResizeUp = {
			desc = "Resize to panel up",
			icon = icons.arrow.collapse_up,
		},
		LYRDPaneResizeRight = {
			desc = "Resize to panel right",
			icon = icons.arrow.collapse_right,
		},
		LYRDPaneSwapLeft = {
			desc = "Swap to panel left",
			icon = icons.arrow.expand_left,
		},
		LYRDPaneSwapDown = {
			desc = "Swap to panel below",
			icon = icons.arrow.expand_down,
		},
		LYRDPaneSwapUp = {
			desc = "Swap to panel up",
			icon = icons.arrow.expand_up,
		},
		LYRDPaneSwapRight = {
			desc = "Swap to panel right",
			icon = icons.arrow.expand_right,
		},
		LYRDDatabaseUI = {
			desc = "Database UI",
			icon = icons.other.database,
		},
		LYRDContainersUI = {
			desc = "Running containers UI",
			icon = icons.other.docker,
		},
		LYRDKubernetesUI = {
			desc = "Kubernetes UI",
			icon = icons.other.kubernetes,
		},
		LYRDScratchNew = {
			desc = "Create a new scratch",
			icon = icons.file.scratch,
		},
		LYRDScratchOpen = {
			desc = "Select scratch file to open",
			icon = icons.search.files,
		},
		LYRDScratchSearch = {
			desc = "Search inside scratches",
			icon = icons.search.lines,
		},
		LYRDReplace = {
			desc = "Search and replace in current file",
			icon = icons.action.replace_text,
		},
		LYRDReplaceInFiles = {
			desc = "Search and replace in files",
			icon = icons.action.replace_in_files,
		},
		LYRDWindowZoom = {
			desc = "Toggles zoom in the selected window",
			icon = icons.other.expand,
		},
		LYRDHttpEnvironmentFileSelect = {
			desc = "Select the http environment file",
			icon = icons.http.environment,
		},
		LYRDHttpEnvironmentSelect = {
			desc = "Select the http environment",
			icon = icons.http.environment,
		},
		LYRDHttpSendRequest = {
			desc = "Send http request",
			icon = icons.http.send,
		},
		LYRDHttpSendAllRequests = {
			desc = "Send all http request",
			icon = icons.http.send,
		},
		LYRDApplyCurrentTheme = {
			desc = "Apply current theme",
			icon = icons.other.palette,
		},
		LYRDApplyNextTheme = {
			desc = "Apply next favorite theme",
			icon = icons.other.palette,
		},
		LYRDClearSearchHighlights = {
			default = ":noh",
			desc = "Clear search highlights",
			icon = icons.other.palette,
		},
		LYRDViewCodeOutline = {
			desc = "View code outline",
			icon = icons.code.outline,
		},
		LYRDViewTreeSitterPlayground = {
			desc = "TreeSitter playground",
			icon = icons.code.outline,
		},
	},
}

function L.settings(s)
	commands.register(s, L.cmd)
end

return L
