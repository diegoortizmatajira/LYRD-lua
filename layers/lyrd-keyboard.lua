local setup = require("LYRD.shared.setup")
local mappings = require("LYRD.layers.mappings")
local menu_header = mappings.menu_header
local submode_header = mappings.submode_header
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

---@class LYRD.layer.LYRDKeyboard: LYRD.shared.setup.Module
local L = {
	name = "LYRD Keyboard",
	vscode_compatible = true,
	unskippable = true,
	ai_keys = {
		-- Accept the current completion.
		-- accept = "<C-l>",
		accept = "<Right>",
		-- Accept the next word.
		accept_word = "<C-Right>",
		-- Accept the next line.
		accept_line = "<C-PageDown>",
		-- Clear the virtual text.
		clear = "<C-Left>",
		-- Cycle to the next completion.
		next = "<C-Down>",
		-- Cycle to the previous completion.
		prev = "<C-Up>",
	},
	bookmark_keys = {
		toggle = "<tab><tab>", -- Toggle bookmark search (global keymap)
		add_workspace = "<leader>bb", -- Add workspace bookmarks(global keymap)
		add_global = "<leader>bg", -- Add global bookmarks(global keymap)
		delete = "<leader>bd", -- Delete bookmarks on the current line(global keymap)
		show_desc = "<leader>bs", -- Show bookmark description and jump to the bookmark(global keymap)
		show = "<leader>bm", -- Show all bookmarks(global keymap)
	},
}

function L.plugins()
	setup.plugin({
		{
			-- Navigates using brackets (buffers, diagnostics, etc.)
			"echasnovski/mini.bracketed",
			opts = {
				buffer = { suffix = "" }, -- disable buffer navigation (handled manually)
			},
		},
		{
			-- Text operators g=: evaluate, gx: exchange, multiply: gm, sort: gs, replace with register: gr
			"echasnovski/mini.operators",
			opts = {},
		},
		{
			-- new a/i objects around/inside next/last
			"echasnovski/mini.ai",
			opts = {},
		},
		{
			-- Splits/Joins arguments in functions with gS
			"echasnovski/mini.splitjoin",
			opts = {},
		},
		{
			-- Adds the completing pair character when typing the opening one
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			opts = {},
			config = function(_, opts)
				require("nvim-autopairs").setup(opts)
				-- If you want insert `(` after select function or method item
				local cmp = require("cmp")
				cmp.event:on(
					"confirm_done",
					require("nvim-autopairs.completion.cmp").on_confirm_done({
						tex = false,
					})
				)
			end,
			dependencies = {
				"hrsh7th/nvim-cmp",
			},
		},
		{
			-- Allows to toggle comments with gc/gcc keymaps
			"numToStr/Comment.nvim",
			opts = {},
		},
		{
			-- Adds surround text objects with pairs of characters.
			"kylechui/nvim-surround",
			event = "VeryLazy",
			opts = {},
		},
	})
end

function L.keybindings()
	-- Use standard nvim key mapping to disable q for recording macros.
	vim.keymap.set("n", "q", "<nop>")
	-- Use standard nvim key mapping to set <leader> + q to start/stop
	-- recording macros using the default q keymap while allowing the user to
	-- press a register key of their choice after pressing <leader> + q.
	vim.keymap.set("n", "<leader>q", "q", { desc = "Start/stop recording macro", noremap = true })

	mappings.keys({
		-- Manual brackaeted mappings for buffers to override mini.bracketed defaults
		{ "n", "[b", cmd.LYRDBufferPrev },
		{ "n", "]b", cmd.LYRDBufferNext },
		-- Manual bindings
		{ "i", "<C-s>", cmd.LYRDBufferSave },
		{ "i", "<M-C-[>", cmd.LYRDBufferPrev },
		{ "i", "<M-C-]>", cmd.LYRDBufferNext },
		{ "n", "<C-S-k>", cmd.LYRDLSPSignatureHelp },
		{ "n", "<C-f>", cmd.LYRDResumeLastSearch },
		{ "n", "<C-h>", cmd.LYRDPaneNavigateLeft },
		{ "n", "<C-j>", cmd.LYRDPaneNavigateDown },
		{ "n", "<C-k>", cmd.LYRDPaneNavigateUp },
		{ "n", "<C-l>", cmd.LYRDPaneNavigateRight },
		{ "n", "<C-p>", cmd.LYRDSearchFiles },
		{ "n", "<M-C-p>", cmd.LYRDSearchAllFiles },
		{ "n", "<C-S-p>", cmd.LYRDSearchAllFiles },
		{ "n", "<C-r><C-f>", cmd.LYRDCodeRefactor },
		{ "n", "<C-r><C-r>", cmd.LYRDLSPRename },
		{ "n", "<C-s>", cmd.LYRDBufferSave },
		{ "n", "<C-t>", cmd.LYRDSearchLiveGrep },
		{ "n", "<C-B>", cmd.LYRDCodeBuildAll },
		{ "n", "<C-M-b>", cmd.LYRDCodeBuild },
		{ "n", "<F10>", cmd.LYRDDebugStepOver },
		{ "n", "<F11>", cmd.LYRDDebugStepInto },
		{ "n", "<F12>", cmd.LYRDDebugStepOut },
		{ "n", "<F2>", cmd.LYRDViewFileTree },
		{ "n", "<F3>", cmd.LYRDTestSummary },
		{ "n", "<F4>", cmd.LYRDViewCodeOutline },
		{ "n", "<F5>", cmd.LYRDDebugContinue },
		{ "n", "<F9>", cmd.LYRDDebugBreakpoint },
		{ "n", "<M-C-[>", cmd.LYRDBufferPrev },
		{ "n", "<M-C-]>", cmd.LYRDBufferNext },
		{ "n", "<M-Enter>", cmd.LYRDLSPFindCodeActions },
		{ "n", "<C-.>", cmd.LYRDLSPFindCodeActions },
		{ "n", "<M-PageDown>", cmd.LYRDLSPGotoNextDiagnostic },
		{ "n", "<M-PageUp>", cmd.LYRDLSPGotoPrevDiagnostic },
		{ "n", "<M-z>", cmd.LYRDBufferToggleWrap },
		{ "n", "<S-CR>", cmd.LYRDCodeRunSelection },
		{ "n", "<S-F5>", cmd.LYRDDebugStart },
		{ "n", "K", cmd.LYRDLSPHoverInfo },
		{ "n", "s", "<nop>" },
		{ "v", "<C-r><C-f>", cmd.LYRDCodeRefactor },
		{ "n", "<M-S-f>", cmd.LYRDBufferFormat },
		{ "n", "ZX", cmd.LYRDWindowForceCloseAll },
	})

	mappings.create_menu("g", {
		{ "d", cmd.LYRDLSPFindDefinitions },
		{ "D", cmd.LYRDLSPFindDeclaration },
		{ "i", cmd.LYRDLSPFindImplementations },
		{ "o", cmd.LYRDInsertLineBelow },
		{ "O", cmd.LYRDInsertLineAbove },
		{ "r", cmd.LYRDLSPFindReferences },
		{ "t", cmd.LYRDLSPFindTypeDefinition },
		menu_header("y", "Yank", {
			{ "a", cmd.LYRDCopyAbsoluteFilePath },
			{ "f", cmd.LYRDCopyFileName },
			{ "r", cmd.LYRDCopyRelativeFilePath },
			{ "w", cmd.LYRDCopyWorkingDirectory },
		}, icons.action.copy),
	})

	mappings.create_menu("<Leader>", {
		menu_header("a", "Artificial Intelligence", {
			{ "a", cmd.LYRDAIAssistant, { "x" } },
			{ "k", cmd.LYRDAIAsk, { "x" } },
			{ "e", cmd.LYRDAIEdit, { "x" } },
			{ "c", cmd.LYRDAICli },
			{ "C", cmd.LYRDAICliSelect },
			{ "d", cmd.LYRDAIGenerateDocumentation, { "x" } },
			{ "p", cmd.LYRDAICliPrompt },
		}, icons.other.ia, { "x" }),
		menu_header("b", "Bookmarks", {
			{ "a", cmd.LYRDBookmarkAddLocal },
			{ "g", cmd.LYRDBookmarkAddGlobal },
			{ "d", cmd.LYRDBookmarkDelete },
			{ "s", cmd.LYRDBookmarkSearch },
			{ "t", cmd.LYRDBookmarkToggle },
		}, icons.other.bookmark),
		menu_header("i", "Images", {
			{ "p", cmd.LYRDPasteImage },
			{ "i", cmd.LYRDInsertImage },
		}, icons.images.default),
		menu_header("n", "Notebook", {
			menu_header("r", "Run", {
				{ "X", cmd.LYRDReplNotebookRunCell },
				{ "x", cmd.LYRDReplNotebookRunCellAndMove },
				{ "e", cmd.LYRDReplNotebookRunAllCells },
				{ "a", cmd.LYRDReplNotebookRunAllAbove },
				{ "b", cmd.LYRDReplNotebookRunAllBelow },
			}, icons.code.run),
			menu_header("m", "Move", {
				{ "u", cmd.LYRDReplNotebookMoveCellUp },
				{ "d", cmd.LYRDReplNotebookMoveCellDown },
			}, icons.action.move),
			{ "n", cmd.LYRDReplView },
			{ "<BS>", cmd.LYRDReplRestart },
			{ "x", cmd.LYRDReplNotebookRunCellAndMove },
			{ "a", cmd.LYRDReplNotebookAddCellAbove },
			{ "b", cmd.LYRDReplNotebookAddCellBelow },
		}, icons.file.notebook),
		submode_header("G", "Debug", {
			{ "g", cmd.LYRDDebugStart },
			{ "d", cmd.LYRDDebugContinue },
			{ "v", cmd.LYRDDebugStepInto },
			{ "f", cmd.LYRDDebugStepOver },
			{ "r", cmd.LYRDDebugStepOut },
			{ "e", cmd.LYRDDebugStop },
			{ "b", cmd.LYRDDebugBreakpoint },
		}, icons.debug.breakpoint, true),
		menu_header("s", "Scratches", {
			{ "f", cmd.LYRDScratchSearch },
			{ "n", cmd.LYRDScratchNew },
			{ "s", cmd.LYRDScratchOpen },
			{ "d", cmd.LYRDScratchDelete },
		}, icons.file.scratch),
		{ "r", cmd.LYRDBufferReload },
		menu_header("R", "Refactors", {
			{ "f", cmd.LYRDCodeRefactor },
			{ "n", cmd.LYRDLSPRename },
		}, icons.code.refactor),
		menu_header(".", function()
			return "'" .. vim.bo.filetype .. "' specific commands"
		end, {}, icons.filetype_icon),
		menu_header("<Leader>", "Panels", {
			submode_header("r", "Resize", {
				{ "j", cmd.LYRDPaneResizeDown },
				{ "k", cmd.LYRDPaneResizeUp },
				{ "h", cmd.LYRDPaneResizeLeft },
				{ "l", cmd.LYRDPaneResizeRight },
			}, icons.arrow.collapse),
			submode_header("s", "Swap", {
				{ "j", cmd.LYRDPaneSwapDown },
				{ "k", cmd.LYRDPaneSwapUp },
				{ "h", cmd.LYRDPaneSwapLeft },
				{ "l", cmd.LYRDPaneSwapRight },
			}, icons.arrow.swap),
			{ ".", cmd.LYRDViewHomePage },
			{ "/", cmd.LYRDSearchBuffers },
			{ "D", cmd.LYRDLSPShowWorkspaceDiagnosticLocList },
			{ "E", cmd.LYRDViewFileExplorerAlt },
			{ "P", cmd.LYRDViewTreeSitterPlayground },
			{ "T", cmd.LYRDTestOutput },
			{ "X", cmd.LYRDTerminal },
			{ "b", cmd.LYRDDatabaseOutput },
			{ "d", cmd.LYRDLSPShowDocumentDiagnosticLocList },
			{ "e", cmd.LYRDViewFileExplorer },
			{ "f", cmd.LYRDViewFileTree },
			{ "g", cmd.LYRDDebugToggleUI },
			{ "h", cmd.LYRDBufferSplitH },
			{ "l", cmd.LYRDViewLocationList },
			{ "o", cmd.LYRDViewCodeOutline },
			{ "q", cmd.LYRDViewQuickFixList },
			{ "s", cmd.LYRDDatabaseUI },
			{ "t", cmd.LYRDTestSummary },
			{ "v", cmd.LYRDBufferSplitV },
			{ "w", cmd.LYRDTasksToggle },
			{ "x", cmd.LYRDTerminalList },
		}, icons.action.split_v),
		{ "<Enter>", cmd.LYRDWindowZoom },
		{ "<Space>", cmd.LYRDClearSearchHighlights },
		{ "c", cmd.LYRDBufferClose },
		{ "f", cmd.LYRDBufferFormat },
		{ "g", cmd.LYRDGrammarToggle },
		{ "j", cmd.LYRDSmartCoder },
		{ "k", cmd.LYRDToggleBufferDecorations },
		{ "d", cmd.LYRDDiagnosticLinesToggle },
		{ "p", cmd.LYRDPasteFromHistory },
		{ "t", cmd.LYRDEditTextCase, { "x" } },
		{ "T", cmd.LYRDApplyNextTheme },
		{ "y", cmd.LYRDCodeQuerySelection, { "x" } },
		{ "Y", cmd.LYRDCodeQuerySelectionAsEditable, { "x" } },
		{ "x", cmd.LYRDCodeRunSelection, { "x" } },
		{ "X", cmd.LYRDCodeRun },
		{ "]", cmd.LYRDBufferNext },
		{ "[", cmd.LYRDBufferPrev },
		{ "/", cmd.LYRDSearchBuffers },
	})

	mappings.create_menu("<Space>", {
		menu_header("b", "Buffers", {
			{ "c", cmd.LYRDBufferClearContent },
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
		}, icons.file.default),
		menu_header("c", "Code", {
			menu_header("g", "Code Generation", {
				{ "x", cmd.LYRDCodeGenerate },
				{ "g", cmd.LYRDCodeProduceGetter },
				{ "s", cmd.LYRDCodeProduceSetter },
				{ "m", cmd.LYRDCodeProduceMapping },
			}, icons.code.generate),
			menu_header("n", "Notebook", {
				menu_header("r", "Run", {
					{ "X", cmd.LYRDReplNotebookRunCell },
					{ "x", cmd.LYRDReplNotebookRunCellAndMove },
					{ "e", cmd.LYRDReplNotebookRunAllCells },
					{ "a", cmd.LYRDReplNotebookRunAllAbove },
					{ "b", cmd.LYRDReplNotebookRunAllBelow },
				}, icons.code.run),
				menu_header("m", "Move", {
					{ "u", cmd.LYRDReplNotebookMoveCellUp },
					{ "d", cmd.LYRDReplNotebookMoveCellDown },
				}, icons.action.move),
				{ "n", cmd.LYRDReplView },
				{ "<BS>", cmd.LYRDReplRestart },
				{ "x", cmd.LYRDReplNotebookRunCellAndMove },
				{ "a", cmd.LYRDReplNotebookAddCellAbove },
				{ "b", cmd.LYRDReplNotebookAddCellBelow },
			}, icons.file.notebook),
			menu_header("s", "Snippet", {
				{ "i", cmd.LYRDCodeInsertSnippet, { "x" } },
				{ "c", cmd.LYRDCodeCreateSnippet },
				{ "e", cmd.LYRDCodeEditSnippet },
			}, icons.action.move, { "x" }),
			{ "A", cmd.LYRDLSPFindRangeCodeActions },
			{ "B", cmd.LYRDCodeBuild },
			{ "I", cmd.LYRDCodeImplementInterface },
			{ "a", cmd.LYRDLSPFindCodeActions },
			{ "b", cmd.LYRDCodeBuildAll },
			{ "c", cmd.LYRDCodeTooling },
			{ "C", cmd.LYRDCodeGlobalCheck },
			{ "e", cmd.LYRDCodeSelectEnvironment },
			{ "f", cmd.LYRDCodeFillStructure },
			{ "i", cmd.LYRDCodeFixImports },
			{ "l", cmd.LYRDDiagnosticLinesToggle },
			{ "p", cmd.LYRDCodeRestorePackages },
			{ "r", cmd.LYRDCodeRefactor },
			{ "S", cmd.LYRDCodeSecrets },
			{ "t", cmd.LYRDCodeAlternateFile },
			{ "x", cmd.LYRDCodeRun },
			{ "v", cmd.LYRDCodeLanguageVersion },
			{ "o", cmd.LYRDCodeOrganizeFile },
		}, icons.other.code, { "x" }),
		menu_header("d", "Debug", {
			{ "y", cmd.LYRDDebugStart },
			{ "k", cmd.LYRDDebugContinue },
			{ "j", cmd.LYRDDebugStepInto },
			{ "l", cmd.LYRDDebugStepOver },
			{ "u", cmd.LYRDDebugStepOut },
			{ "h", cmd.LYRDDebugStop },
			{ "b", cmd.LYRDDebugBreakpoint },
			{ ";", cmd.LYRDDebugToggleUI },
			{ "/", cmd.LYRDDebugToggleRepl },
		}, icons.debug.breakpoint),
		menu_header("s", "Search", {
			{ ",", cmd.LYRDSearchCommands },
			{ ".", cmd.LYRDSearchFiles },
			{ "/", cmd.LYRDSearchLiveGrep },
			{ "B", cmd.LYRDSearchBuffers },
			{ "C", cmd.LYRDSearchCommandHistory },
			{ "G", cmd.LYRDSearchBufferTags },
			{ "H", cmd.LYRDSearchHighlights },
			{ "M", cmd.LYRDSearchMacros },
			{ "r", cmd.LYRDReplaceInFiles },
			{ "S", cmd.LYRDSearchCurrentString },
			{ "T", cmd.LYRDTerminalList },
			{ "b", cmd.LYRDBookmarkSearch },
			{ "f", cmd.LYRDSearchFiletypes },
			{ "g", cmd.LYRDSearchGitFiles },
			{ "h", cmd.LYRDSearchRecentFiles },
			{ "k", cmd.LYRDSearchKeyMappings },
			{ "l", cmd.LYRDSearchBufferLines },
			{ "m", cmd.LYRDViewMarks },
			{ "n", cmd.LYRDSearchSnippets },
			{ "o", cmd.LYRDSearchSymbols },
			{ "p", cmd.LYRDSearchRegisters },
			{ "q", cmd.LYRDSearchQuickFixes },
			{ "R", cmd.LYRDReplace },
			{ "s", cmd.LYRDLSPFindDocumentSymbols },
			{ "S", cmd.LYRDLSPFindWorkspaceSymbols },
			{ "t", cmd.LYRDSearchColorSchemes },
		}, icons.search.default),
		menu_header("g", "Git", {
			menu_header("f", "Gitflow", {
				{ "i", cmd.LYRDGitFlowInit },
				menu_header("f", "Feature", {
					{ "s", cmd.LYRDGitFlowFeatureStart },
					{ "f", cmd.LYRDGitFlowFeatureFinish },
					{ "p", cmd.LYRDGitFlowFeaturePublish },
				}),
				menu_header("r", "Release", {
					{ "s", cmd.LYRDGitFlowReleaseStart },
					{ "f", cmd.LYRDGitFlowReleaseFinish },
					{ "p", cmd.LYRDGitFlowReleasePublish },
				}),
				menu_header("h", "Hotfix", {
					{ "s", cmd.LYRDGitFlowHotfixStart },
					{ "f", cmd.LYRDGitFlowHotfixFinish },
					{ "p", cmd.LYRDGitFlowHotfixPublish },
				}),
				{ "D", cmd.LYRDGitCheckoutDev },
				{ "M", cmd.LYRDGitCheckoutMain },
			}),
			menu_header("h", "GitHub", {
				menu_header("i", "Issue", {
					{ "l", cmd.LYRDGithubIssueList },
					{ "c", cmd.LYRDGithubIssueCreate },
					{ "x", cmd.LYRDGithubIssueClose },
					{ "r", cmd.LYRDGithubIssueReopen },
					{ "d", cmd.LYRDGithubIssueDevelop },
				}, icons.git.issue.open),
				menu_header("p", "Pull Request", {
					{ "c", cmd.LYRDGithubPullRequestCreate },
					{ "l", cmd.LYRDGithubPullRequestList },
					{ "x", cmd.LYRDGithubPullRequestClose },
				}, icons.git.pull_request),
				menu_header("r", "Release", {
					{ "c", cmd.LYRDGithubReleaseCreate },
				}, icons.git.tag),
			}, icons.git.github),
			menu_header("w", "Worktrees", {
				{ "t", cmd.LYRDGitWorkTreeList },
				{ "n", cmd.LYRDGitWorkTreeCreate },
				{ "e", cmd.LYRDGitWorkTreeCreateExistingBranch },
			}),
			{ "m", cmd.LYRDGitMergeConflicts },
			{ "g", cmd.LYRDGitUI },
			{ "G", cmd.LYRDGitViewGraph },
			{ "s", cmd.LYRDGitStatus },
			{ "c", cmd.LYRDGitCommit },
			{ "P", cmd.LYRDGitPush },
			{ "p", cmd.LYRDGitPull },
			{ "d", cmd.LYRDGitViewDiff },
			{ "D", cmd.LYRDGitCompareWithBranch },
			{ "a", cmd.LYRDGitStageAll },
			{ "b", cmd.LYRDGitViewBlame },
			{ "l", cmd.LYRDGitViewCurrentFileLog },
			{ "x", cmd.LYRDGitBrowseOnWeb },
		}, icons.git.default),
		menu_header("t", "Test", {
			{ "t", cmd.LYRDTest },
			{ "s", cmd.LYRDTestSuite },
			{ "b", cmd.LYRDTestFile },
			{ "F", cmd.LYRDTestDebugFunc },
			{ "f", cmd.LYRDTestFunc },
			{ "h", cmd.LYRDTestLast },
			{ "c", cmd.LYRDTestCoverage },
			{ "s", cmd.LYRDTestCoverageSummary },
			{ "v", cmd.LYRDTestSummary },
		}, icons.code.test),
		menu_header("p", "Preferences", {
			{ "c", cmd.LYRDPluginsClean },
			{ "d", cmd.LYRDUpdateDistro },
			{ "i", cmd.LYRDPluginsInstall },
			{ "l", cmd.LYRDEditLocalConfig },
			{ "p", cmd.LYRDPluginManager },
			{ "t", cmd.LYRDToolManager },
			{ "u", cmd.LYRDPluginsUpdate },
		}, icons.other.briefcase),
		menu_header("q", "Quit", {
			{ ".", cmd.LYRDWindowClose },
			{ "q", cmd.LYRDWindowForceCloseAll },
			{ "Q", cmd.LYRDWindowForceCloseAll },
		}, icons.action.exit),
		menu_header("r", "Run", {
			menu_header("R", "REPL", {
				{ "v", cmd.LYRDReplView },
				{ "r", cmd.LYRDReplRestart },
			}, icons.other.command),
			{ "r", cmd.LYRDTasksRun },
			{ "t", cmd.LYRDTasksToggle },
			{ "T", cmd.LYRDTasksConfigure },
			{ "L", cmd.LYRDTasksConfigureLaunch },
		}, icons.code.run),
		menu_header("<SPACE>", "Tools/Services", {
			{ "d", cmd.LYRDDatabaseUI },
			{ "c", cmd.LYRDContainersUI },
			{ "f", cmd.LYRDViewFileExplorer },
			{ "F", cmd.LYRDViewFileExplorerAlt },
			{ "g", cmd.LYRDGitUI },
			{ "k", cmd.LYRDKubernetesUI },
			{ "t", cmd.LYRDTerminal },
			{ "T", cmd.LYRDTerminalList },
			{ "s", cmd.LYRDDevServerStart },
			{ "S", cmd.LYRDDevExposeLocalServer },
			{ "x", cmd.LYRDScanForSecrets },
			{ "<Space>", cmd.LYRDCommandPalette },
		}, icons.other.tools),
		menu_header("u", "User interface", {
			{ "h", cmd.LYRDHardModeToggle },
		}, icons.other.palette),
		menu_header("v", "View", {
			{ ".", cmd.LYRDViewHomePage },
			{ "d", cmd.LYRDDiffThis },
			{ "D", cmd.LYRDDiffOff },
			{ "f", cmd.LYRDViewFocusMode },
			{ "l", cmd.LYRDViewLSPInfo },
			{ "w", cmd.LYRDBufferToggleWrap },
			{ "s", cmd.LYRDBindScroll },
			{ "T", cmd.LYRDApplyCurrentTheme },
			{ "t", cmd.LYRDApplyNextTheme },
		}, icons.action.view),
	})
end

return L
