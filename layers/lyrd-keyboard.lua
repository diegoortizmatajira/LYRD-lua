local mappings = require("LYRD.layers.mappings")
local menu_header = mappings.menu_header
local submode_header = mappings.submode_header
local commands = require("LYRD.layers.commands")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "LYRD Keyboard",
	ai_keys = {
		-- Accept the current completion.
		accept = "<S-Right>",
		-- Accept the next word.
		accept_word = "<S-Left>",
		-- Accept the next line.
		accept_line = "<S-End>",
		-- Clear the virtual text.
		clear = "<S-Del>",
		-- Cycle to the next completion.
		next = "<S-Up>",
		-- Cycle to the previous completion.
		prev = "<S-Down>",
	},
}

function L.keybindings(s)
	mappings.keys(s, {
		{ "n", "<C-j>", cmd.LYRDPaneNavigateDown },
		{ "n", "<C-k>", cmd.LYRDPaneNavigateUp },
		{ "n", "<C-h>", cmd.LYRDPaneNavigateLeft },
		{ "n", "<C-l>", cmd.LYRDPaneNavigateRight },
		{ "n", "q", "<nop>" },
		{ "n", "s", "<nop>" },
		{ "n", "<F2>", cmd.LYRDViewFileTree },
		{ "n", "<F3>", cmd.LYRDViewFileExplorer },
		{ "n", "<F4>", cmd.LYRDTestSummary },
		{ "n", "<F5>", cmd.LYRDDebugContinue },
		{ "n", "<F6>", cmd.LYRDViewCodeOutline },
		{ "n", "<F9>", cmd.LYRDDebugBreakpoint },
		{ "n", "<F10>", cmd.LYRDDebugStepOver },
		{ "n", "<F11>", cmd.LYRDDebugStepInto },
		{ "n", "<C-s>", cmd.LYRDBufferSave },
		{ "i", "<C-s>", "<Esc>" .. c(cmd.LYRDBufferSave.name) },
		{ "n", "<C-p>", cmd.LYRDSearchFiles },
		{ "n", "<C-t>", cmd.LYRDSearchLiveGrep },
		{ "n", "<C-f>", cmd.LYRDResumeLastSearch },
		{ "n", "<A-Left>", cmd.LYRDBufferPrev },
		{ "n", "<A-Right>", cmd.LYRDBufferNext },
		{ "n", "K", cmd.LYRDLSPHoverInfo },
		{ "n", "<C-S-k>", cmd.LYRDLSPSignatureHelp },
		{ "n", "gd", cmd.LYRDLSPFindDefinitions },
		{ "n", "gD", cmd.LYRDLSPFindDeclaration },
		{ "n", "gt", cmd.LYRDLSPFindTypeDefinition },
		{ "n", "gi", cmd.LYRDLSPFindImplementations },
		{ "n", "gr", cmd.LYRDLSPFindReferences },
		{ "n", "gO", c([[call append(line('.')-1, '')]]) },
		{ "n", "go", c([[call append(line('.'), '')]]) },
		{ "n", "<A-PageUp>", cmd.LYRDLSPGotoPrevDiagnostic },
		{ "n", "<A-PageDown>", cmd.LYRDLSPGotoNextDiagnostic },
		{ "n", "<A-Enter>", cmd.LYRDLSPFindCodeActions },
		{ "n", "<C-r><C-r>", cmd.LYRDLSPRename },
		{ "n", "<C-r><C-f>", cmd.LYRDCodeRefactor },
		{ "v", "<C-r><C-f>", cmd.LYRDCodeRefactor },
	})

	mappings.create_menu("<Leader>", {
		menu_header("h", "Http Requests", {
			{ "a", cmd.LYRDHttpSendAllRequests },
			{ "e", cmd.LYRDHttpEnvironmentFileSelect },
			{ "h", cmd.LYRDHttpSendRequest },
		}),
		menu_header("s", "Scratches", {
			{ "f", cmd.LYRDScratchSearch },
			{ "n", cmd.LYRDScratchNew },
			{ "s", cmd.LYRDScratchOpen },
		}),
		menu_header("r", "Refactors", {
			{ "f", cmd.LYRDCodeRefactor },
			{ "n", cmd.LYRDLSPRename },
		}),
		menu_header("<Leader>", "Panels", {
			submode_header("r", "Resize", {
				{ "j", cmd.LYRDPaneResizeDown },
				{ "k", cmd.LYRDPaneResizeUp },
				{ "h", cmd.LYRDPaneResizeLeft },
				{ "l", cmd.LYRDPaneResizeRight },
			}),
			submode_header("s", "Swap", {
				{ "j", cmd.LYRDPaneSwapDown },
				{ "k", cmd.LYRDPaneSwapUp },
				{ "h", cmd.LYRDPaneSwapLeft },
				{ "l", cmd.LYRDPaneSwapRight },
			}),
			{ ".", cmd.LYRDViewHomePage },
			{ "D", cmd.LYRDLSPShowWorkspaceDiagnosticLocList },
			{ "c", cmd.LYRDViewRegisters },
			{ "d", cmd.LYRDLSPShowDocumentDiagnosticLocList },
			{ "e", cmd.LYRDViewFileExplorer },
			{ "f", cmd.LYRDViewFileTree },
			{ "g", cmd.LYRDDebugToggleUI },
			{ "h", cmd.LYRDBufferSplitH },
			{ "l", cmd.LYRDViewLocationList },
			{ "o", cmd.LYRDViewCodeOutline },
			{ "p", cmd.LYRDViewTreeSitterPlayground },
			{ "q", cmd.LYRDViewQuickFixList },
			{ "t", cmd.LYRDTestSummary },
			{ "v", cmd.LYRDBufferSplitV },
			{ "y", cmd.LYRDViewYankList },
		}),
		{ "<Enter>", cmd.LYRDWindowZoom },
		{ "<Space>", cmd.LYRDClearSearchHighlights },
		{ "a", cmd.LYRDLSPFindCodeActions },
		{ "c", cmd.LYRDBufferClose },
		{ "f", cmd.LYRDBufferFormat },
		{ "j", cmd.LYRDSmartCoder },
		{ "d", cmd.LYRDDiagnosticLinesToggle },
		{ "t", cmd.LYRDApplyNextTheme },
		{ "x", cmd.LYRDBufferNext },
		{ "z", cmd.LYRDBufferPrev },
	})

	mappings.create_menu("<Space>", {
		menu_header("a", "Artificial Intelligence", {
			{ "a", cmd.LYRDAIAssistant },
			{ "r", cmd.LYRDAIRefactor },
			{ "s", cmd.LYRDAISuggestions },
		}),
		menu_header("b", "Buffers", {
			{ "e", cmd.LYRDBufferNew },
			{ "n", cmd.LYRDBufferNext },
			{ "p", cmd.LYRDBufferPrev },
			{ "d", cmd.LYRDBufferClose },
			{ "D", cmd.LYRDBufferForceClose },
			{ "f", cmd.LYRDBufferFormat },
			{ "x", cmd.LYRDBufferCloseAll },
			{ "X", cmd.LYRDBufferForceCloseAll },
			{ "h", cmd.LYRDBufferSplitH },
			{ "v", cmd.LYRDBufferSplitV },
			{ "w", cmd.LYRDBufferSetReadOnly },
			{ "Y", cmd.LYRDBufferCopy },
			{ "P", cmd.LYRDBufferPaste },
			{ "/", cmd.LYRDSearchBuffers },
			{ "s", cmd.LYRDBufferSave },
			{ "S", cmd.LYRDBufferSaveAll },
		}),
		menu_header("c", "Code", {
			menu_header("g", "Code Generation", {
				{ "x", cmd.LYRDCodeGenerate },
				{ "g", cmd.LYRDCodeProduceGetter },
				{ "s", cmd.LYRDCodeProduceSetter },
				{ "m", cmd.LYRDCodeProduceMapping },
			}),
			{ "A", cmd.LYRDLSPFindRangeCodeActions },
			{ "B", cmd.LYRDCodeBuildAll },
			{ "I", cmd.LYRDCodeImplementInterface },
			{ "R", cmd.LYRDCodeRefactor },
			{ "a", cmd.LYRDLSPFindCodeActions },
			{ "b", cmd.LYRDCodeBuild },
			{ "c", cmd.LYRDCodeGlobalCheck },
			{ "f", cmd.LYRDCodeFillStructure },
			{ "i", cmd.LYRDCodeFixImports },
			{ "l", cmd.LYRDDiagnosticLinesToggle },
			{ "p", cmd.LYRDCodeRestorePackages },
			{ "r", cmd.LYRDCodeRun },
			{ "S", cmd.LYRDCodeSecrets },
			{ "s", cmd.LYRDCodeInsertSnippet },
			{ "t", cmd.LYRDCodeAlternateFile },
		}),
		menu_header("d", "Debug", {
			{ "k", cmd.LYRDDebugContinue },
			{ "j", cmd.LYRDDebugStepInto },
			{ "l", cmd.LYRDDebugStepOver },
			{ "h", cmd.LYRDDebugStop },
			{ "b", cmd.LYRDDebugBreakpoint },
			{ ";", cmd.LYRDDebugToggleUI },
			{ "/", cmd.LYRDDebugToggleRepl },
		}),
		menu_header("f", "Find", {
			{ ".", cmd.LYRDSearchFiles },
			{ "b", cmd.LYRDSearchBuffers },
			{ "g", cmd.LYRDSearchGitFiles },
			{ "h", cmd.LYRDSearchRecentFiles },
			{ "l", cmd.LYRDSearchBufferLines },
			{ "c", cmd.LYRDSearchCommandHistory },
			{ "m", cmd.LYRDSearchKeyMappings },
			{ "t", cmd.LYRDSearchBufferTags },
			{ "/", cmd.LYRDSearchLiveGrep },
			{ "f", cmd.LYRDSearchFiletypes },
			{ "o", cmd.LYRDSearchColorSchemes },
			{ "q", cmd.LYRDSearchQuickFixes },
			{ "H", cmd.LYRDSearchHighlights },
			{ ",", cmd.LYRDSearchCommands },
			{ "s", cmd.LYRDSearchCurrentString },
			{ "p", cmd.LYRDSearchRegisters },
			{ "R", cmd.LYRDReplaceInFiles },
			{ "r", cmd.LYRDReplace },
		}),
		menu_header("g", "Git", {
			menu_header("f", "Gitflow", {
				{ "i", cmd.LYRDGitFlowInit },
				{ "f", cmd.LYRDGitFlowFeatureStart },
				{ "F", cmd.LYRDGitFlowFeatureFinish },
				{ "r", cmd.LYRDGitFlowReleaseStart },
				{ "R", cmd.LYRDGitFlowReleaseFinish },
				{ "h", cmd.LYRDGitFlowHotfixStart },
				{ "H", cmd.LYRDGitFlowHotfixFinish },
				{ "D", cmd.LYRDGitCheckoutDev },
				{ "M", cmd.LYRDGitCheckoutMain },
			}),
			{ "g", cmd.LYRDGitUI },
			{ "s", cmd.LYRDGitStatus },
			{ "c", cmd.LYRDGitCommit },
			{ "p", cmd.LYRDGitPush },
			{ "P", cmd.LYRDGitPull },
			{ "d", cmd.LYRDGitViewDiff },
			{ "a", cmd.LYRDGitStageAll },
			{ "b", cmd.LYRDGitViewBlame },
			{ "l", cmd.LYRDGitViewCurrentFileLog },
			{ "w", cmd.LYRDGitBrowseOnWeb },
		}),
		menu_header("t", "Test", {
			{ "t", cmd.LYRDTest },
			{ "s", cmd.LYRDTestSuite },
			{ "F", cmd.LYRDTestFile },
			{ "f", cmd.LYRDTestFunc },
			{ "h", cmd.LYRDTestLast },
			{ "c", cmd.LYRDTestCoverage },
			{ "v", cmd.LYRDTestSummary },
		}),
		menu_header("p", "Packages", {
			{ "t", cmd.LYRDToolManager },
			{ "p", cmd.LYRDPluginManager },
			{ "i", cmd.LYRDPluginsInstall },
			{ "u", cmd.LYRDPluginsUpdate },
			{ "c", cmd.LYRDPluginsClean },
		}),
		menu_header("q", "Quit", {
			{ ".", cmd.LYRDWindowClose },
			{ "q", cmd.LYRDWindowForceCloseAll },
			{ "Q", cmd.LYRDWindowForceCloseAll },
		}),
		menu_header("r", "Run", {
			menu_header("h", "Http request", {
				{ "f", cmd.LYRDHttpEnvironmentFileSelect },
				{ "e", cmd.LYRDHttpEnvironmentSelect },
				{ "s", cmd.LYRDHttpSendRequest },
				{ "a", cmd.LYRDHttpSendAllRequests },
			}),
		}),
		menu_header("s", "Services", {
			{ "f", cmd.LYRDViewFileExplorer },
			{ "d", cmd.LYRDDatabaseUI },
			{ "c", cmd.LYRDContainersUI },
			{ "g", cmd.LYRDGitUI },
			{ "k", cmd.LYRDKubernetesUI },
			{ "t", cmd.LYRDTerminal },
		}),
		menu_header("u", "User interface", {
			{ "w", cmd.LYRDBufferToggleWrap },
			{ "T", cmd.LYRDApplyCurrentTheme },
			{ "t", cmd.LYRDApplyNextTheme },
		}),
		menu_header("v", "View", {
			{ ".", cmd.LYRDViewHomePage },
			{ "t", cmd.LYRDViewFileTree },
			{ "o", cmd.LYRDViewCodeOutline },
			{ "e", cmd.LYRDViewFileExplorer },
			{ "l", cmd.LYRDViewLocationList },
			{ "r", cmd.LYRDViewRegisters },
			{ "y", cmd.LYRDViewYankList },
			{ "p", cmd.LYRDViewTreeSitterPlayground },
			{ "q", cmd.LYRDViewQuickFixList },
			{ "d", cmd.LYRDLSPShowDocumentDiagnosticLocList },
			{ "D", cmd.LYRDLSPShowWorkspaceDiagnosticLocList },
		}),
		{ "/", cmd.LYRDSearchBuffers },
	})
end

return L
