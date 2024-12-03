local mappings = require("LYRD.layers.mappings")
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
	local submode = require("submode")

	submode.create("PanelResize", {
		mode = "n",
		enter = "<Leader><Leader>r",
		leave = { "q", "<ESC>" },
		default = function(register)
			register("j", c("LYRDPaneResizeDown"))
			register("k", c("LYRDPaneResizeUp"))
			register("h", c("LYRDPaneResizeLeft"))
			register("l", c("LYRDPaneResizeRight"))
		end,
	})
	submode.create("PanelSwap", {
		mode = "n",
		enter = "<Leader><Leader>s",
		leave = { "q", "<ESC>" },
		default = function(register)
			register("j", c("LYRDPaneSwapDown"))
			register("k", c("LYRDPaneSwapUp"))
			register("h", c("LYRDPaneSwapLeft"))
			register("l", c("LYRDPaneSwapRight"))
		end,
	})
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

	mappings.leader_menu(s, {
		{ { "h" }, "Http Requests" },
		{ { "s" }, "Scratches" },
		{ { "r" }, "Refactors" },
		{ { "<Leader>" }, "Panels" },
		{ { "<Leader>", "r" }, "Resize" },
		{ { "<Leader>", "s" }, "Swap" },
	})
	mappings.leader(s, {
		{ "n", { "<Space>" }, c("noh"), "Clear search highlights" },
		{ "n", { "." }, cmd.LYRDViewHomePage },
		{ "n", { "b" }, cmd.LYRDBreakLine },
		{ "n", { "c" }, cmd.LYRDBufferClose },
		{ "n", { "z" }, cmd.LYRDBufferPrev },
		{ "n", { "<Enter>" }, cmd.LYRDWindowZoom },
		{ "n", { "x" }, cmd.LYRDBufferNext },
		{ "n", { "a" }, cmd.LYRDLSPFindCodeActions },
		{ "n", { "f" }, cmd.LYRDBufferFormat },
		{ "n", { "d" }, cmd.LYRDDebugToggleUI },
		{ "n", { "j" }, cmd.LYRDSmartCoder },
		{ "n", { "o" }, cmd.LYRDBufferJumpToLast },
		{ "n", { "l" }, cmd.LYRDDiagnosticLinesToggle },
		{ "n", { "s", "n" }, cmd.LYRDScratchNew },
		{ "n", { "s", "s" }, cmd.LYRDScratchOpen },
		{ "n", { "s", "f" }, cmd.LYRDScratchSearch },
		{ "n", { "r", "n" }, cmd.LYRDLSPRename },
		{ "n", { "r", "f" }, cmd.LYRDCodeRefactor },
		{ "v", { "r", "f" }, cmd.LYRDCodeRefactor },
		{ "n", { "h", "h" }, cmd.LYRDHttpSendRequest },
		{ "n", { "h", "a" }, cmd.LYRDHttpSendAllRequests },
		{ "n", { "h", "e" }, cmd.LYRDHttpEnvironmentFileSelect },
		{ "n", { "<Leader>", "h" }, cmd.LYRDBufferSplitH },
		{ "n", { "<Leader>", "v" }, cmd.LYRDBufferSplitV },
	})
	mappings.space_menu(s, {
		{ { "a" }, "Artificial Intelligence" },
		{ { "b" }, "Buffers" },
		{ { "c" }, "Code" },
		{ { "c", "g" }, "Code Generation" },
		{ { "d" }, "Debug" },
		{ { "f" }, "Find" },
		{ { "g" }, "Git" },
		{ { "g", "f" }, "Gitflow" },
		{ { "t" }, "Test" },
		{ { "p" }, "Packages" },
		{ { "q" }, "Quit" },
		{ { "r" }, "Run" },
		{ { "r", "h" }, "Http request" },
		{ { "s" }, "Services" },
		{ { "u" }, "User interface" },
		{ { "v" }, "View" },
	})
	mappings.space(s, {
		{ "n", { "/" }, cmd.LYRDSearchBuffers },
		-- Artificial Intelligence Menu
		{ "n", { "a", "a" }, cmd.LYRDAIAssistant },
		{ "n", { "a", "r" }, cmd.LYRDAIRefactor },
		{ "n", { "a", "s" }, cmd.LYRDAISuggestions },
		-- View Menu
		{ "n", { "v", "." }, cmd.LYRDViewHomePage },
		{ "n", { "v", "t" }, cmd.LYRDViewFileTree },
		{ "n", { "v", "e" }, cmd.LYRDViewFileExplorer },
		{ "n", { "v", "l" }, cmd.LYRDViewLocationList },
		{ "n", { "v", "r" }, cmd.LYRDViewRegisters },
		{ "n", { "v", "y" }, cmd.LYRDViewYankList },
		{ "n", { "v", "q" }, cmd.LYRDViewQuickFixList },
		{ "n", { "v", "d" }, cmd.LYRDLSPShowDocumentDiagnosticLocList },
		{ "n", { "v", "D" }, cmd.LYRDLSPShowWorkspaceDiagnosticLocList },
		-- Buffer Menu
		{ "n", { "b", "e" }, cmd.LYRDBufferNew },
		{ "n", { "b", "n" }, cmd.LYRDBufferNext },
		{ "n", { "b", "p" }, cmd.LYRDBufferPrev },
		{ "n", { "b", "d" }, cmd.LYRDBufferClose },
		{ "n", { "b", "D" }, cmd.LYRDBufferForceClose },
		{ "n", { "b", "f" }, cmd.LYRDBufferFormat },
		{ "n", { "b", "x" }, cmd.LYRDBufferCloseAll },
		{ "n", { "b", "X" }, cmd.LYRDBufferForceCloseAll },
		{ "n", { "b", "h" }, cmd.LYRDBufferSplitH },
		{ "n", { "b", "v" }, cmd.LYRDBufferSplitV },
		{ "n", { "b", "w" }, cmd.LYRDBufferSetReadOnly },
		{ "n", { "b", "Y" }, cmd.LYRDBufferCopy },
		{ "n", { "b", "P" }, cmd.LYRDBufferPaste },
		{ "n", { "b", "/" }, cmd.LYRDSearchBuffers },
		{ "n", { "b", "s" }, cmd.LYRDBufferSave },
		{ "n", { "b", "S" }, cmd.LYRDBufferSaveAll },
		-- Packages
		{ "n", { "p", "t" }, cmd.LYRDToolManager },
		{ "n", { "p", "p" }, cmd.LYRDPluginManager },
		{ "n", { "p", "i" }, cmd.LYRDPluginsInstall },
		{ "n", { "p", "u" }, cmd.LYRDPluginsUpdate },
		{ "n", { "p", "c" }, cmd.LYRDPluginsClean },
		-- Quit Menu
		{ "n", { "q", "." }, cmd.LYRDWindowClose },
		{ "n", { "q", "q" }, cmd.LYRDWindowForceCloseAll },
		{ "n", { "q", "Q" }, cmd.LYRDWindowForceCloseAll },
		-- Run Menu
		{ "n", { "r", "h", "f" }, cmd.LYRDHttpEnvironmentFileSelect },
		{ "n", { "r", "h", "e" }, cmd.LYRDHttpEnvironmentSelect },
		{ "n", { "r", "h", "s" }, cmd.LYRDHttpSendRequest },
		{ "n", { "r", "h", "a" }, cmd.LYRDHttpSendAllRequests },
		-- UI Menu
		{ "n", { "u", "w" }, cmd.LYRDBufferToggleWrap },
		{ "n", { "u", "T" }, cmd.LYRDApplyCurrentTheme },
		{ "n", { "u", "t" }, cmd.LYRDApplyNextTheme },
		-- Services
		{ "n", { "s", "f" }, cmd.LYRDViewFileExplorer },
		{ "n", { "s", "d" }, cmd.LYRDDatabaseUI },
		{ "n", { "s", "c" }, cmd.LYRDContainersUI },
		{ "n", { "s", "g" }, cmd.LYRDGitUI },
		{ "n", { "s", "k" }, cmd.LYRDKubernetesUI },
		{ "n", { "s", "t" }, cmd.LYRDTerminal },
		-- Search Menu
		{ "n", { "f", "." }, cmd.LYRDSearchFiles },
		{ "n", { "f", "b" }, cmd.LYRDSearchBuffers },
		{ "n", { "f", "g" }, cmd.LYRDSearchGitFiles },
		{ "n", { "f", "h" }, cmd.LYRDSearchRecentFiles },
		{ "n", { "f", "l" }, cmd.LYRDSearchBufferLines },
		{ "n", { "f", "c" }, cmd.LYRDSearchCommandHistory },
		{ "n", { "f", "m" }, cmd.LYRDSearchKeyMappings },
		{ "n", { "f", "t" }, cmd.LYRDSearchBufferTags },
		{ "n", { "f", "/" }, cmd.LYRDSearchLiveGrep },
		{ "n", { "f", "f" }, cmd.LYRDSearchFiletypes },
		{ "n", { "f", "o" }, cmd.LYRDSearchColorSchemes },
		{ "n", { "f", "q" }, cmd.LYRDSearchQuickFixes },
		{ "n", { "f", "H" }, cmd.LYRDSearchHighlights },
		{ "n", { "f", "," }, cmd.LYRDSearchCommands },
		{ "n", { "f", "s" }, cmd.LYRDSearchCurrentString },
		{ "n", { "f", "p" }, cmd.LYRDSearchRegisters },
		{ "n", { "f", "R" }, cmd.LYRDReplaceInFiles },
		{ "n", { "f", "r" }, cmd.LYRDReplace },
		-- Git Menu
		{ "n", { "g", "g" }, cmd.LYRDGitUI },
		{ "n", { "g", "s" }, cmd.LYRDGitStatus },
		{ "n", { "g", "c" }, cmd.LYRDGitCommit },
		{ "n", { "g", "p" }, cmd.LYRDGitPush },
		{ "n", { "g", "P" }, cmd.LYRDGitPull },
		{ "n", { "g", "d" }, cmd.LYRDGitViewDiff },
		{ "n", { "g", "a" }, cmd.LYRDGitStageAll },
		{ "n", { "g", "b" }, cmd.LYRDGitViewBlame },
		{ "n", { "g", "l" }, cmd.LYRDGitViewCurrentFileLog },
		{ "n", { "g", "w" }, cmd.LYRDGitBrowseOnWeb },
		{ "n", { "g", "f", "i" }, cmd.LYRDGitFlowInit },
		{ "n", { "g", "f", "f" }, cmd.LYRDGitFlowFeatureStart },
		{ "n", { "g", "f", "F" }, cmd.LYRDGitFlowFeatureFinish },
		{ "n", { "g", "f", "r" }, cmd.LYRDGitFlowReleaseStart },
		{ "n", { "g", "f", "R" }, cmd.LYRDGitFlowReleaseFinish },
		{ "n", { "g", "f", "h" }, cmd.LYRDGitFlowHotfixStart },
		{ "n", { "g", "f", "H" }, cmd.LYRDGitFlowHotfixFinish },
		{ "n", { "g", "f", "D" }, cmd.LYRDGitCheckoutDev },
		{ "n", { "g", "f", "M" }, cmd.LYRDGitCheckoutMain },
		-- Code Menu
		{ "n", { "c", "a" }, cmd.LYRDLSPFindCodeActions },
		{ "n", { "c", "A" }, cmd.LYRDLSPFindRangeCodeActions },
		{ "n", { "c", "b" }, cmd.LYRDCodeBuild },
		{ "n", { "c", "r" }, cmd.LYRDCodeRun },
		{ "n", { "c", "R" }, cmd.LYRDCodeRefactor },
		{ "n", { "c", "t" }, cmd.LYRDCodeAlternateFile },
		{ "n", { "c", "l" }, cmd.LYRDDiagnosticLinesToggle },
		{ "n", { "c", "i" }, cmd.LYRDCodeFixImports },
		{ "n", { "c", "c" }, cmd.LYRDCodeGlobalCheck },
		{ "n", { "c", "I" }, cmd.LYRDCodeImplementInterface },
		{ "n", { "c", "f" }, cmd.LYRDCodeFillStructure },
		{ "n", { "c", "s" }, cmd.LYRDCodeInsertSnippet },
		{ "n", { "c", "g", "x" }, cmd.LYRDCodeGenerate },
		{ "n", { "c", "g", "g" }, cmd.LYRDCodeProduceGetter },
		{ "n", { "c", "g", "s" }, cmd.LYRDCodeProduceSetter },
		{ "n", { "c", "g", "m" }, cmd.LYRDCodeProduceMapping },
		-- Test menu
		{ "n", { "t", "t" }, cmd.LYRDTest },
		{ "n", { "t", "s" }, cmd.LYRDTestSuite },
		{ "n", { "t", "F" }, cmd.LYRDTestFile },
		{ "n", { "t", "f" }, cmd.LYRDTestFunc },
		{ "n", { "t", "h" }, cmd.LYRDTestLast },
		{ "n", { "t", "c" }, cmd.LYRDTestCoverage },
		{ "n", { "t", "v" }, cmd.LYRDTestSummary },

		-- Debug Menu
		{ "n", { "d", "k" }, cmd.LYRDDebugContinue },
		{ "n", { "d", "j" }, cmd.LYRDDebugStepInto },
		{ "n", { "d", "l" }, cmd.LYRDDebugStepOver },
		{ "n", { "d", "h" }, cmd.LYRDDebugStop },
		{ "n", { "d", "b" }, cmd.LYRDDebugBreakpoint },
		{ "n", { "d", ";" }, cmd.LYRDDebugToggleUI },
		{ "n", { "d", "/" }, cmd.LYRDDebugToggleRepl },
	})
end

return L
