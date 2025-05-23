local setup = require("LYRD.setup")
local mappings = require("LYRD.layers.mappings")
local menu_header = mappings.menu_header
local submode_header = mappings.submode_header
local commands = require("LYRD.layers.commands")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = {
	name = "LYRD Keyboard",
	ai_keys = {
		-- Accept the current completion.
		accept = "<C-l>",
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
}

function L.plugins()
	setup.plugin({
		{
			-- Navigates using brackets (buffers, diagnostics, etc.)
			"echasnovski/mini.bracketed",
			opts = {},
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
			"echasnovski/mini.comment",
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
	mappings.keys({
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
		{ "n", "<M-PageDown>", cmd.LYRDLSPGotoNextDiagnostic },
		{ "n", "<M-PageUp>", cmd.LYRDLSPGotoPrevDiagnostic },
		{ "n", "<M-z>", cmd.LYRDBufferToggleWrap },
		{ "n", "<S-CR>", cmd.LYRDCodeRunSelection },
		{ "n", "<S-F5>", cmd.LYRDDebugStart },
		{ "n", "K", cmd.LYRDLSPHoverInfo },
		{ "n", "gD", cmd.LYRDLSPFindDeclaration },
		{ "n", "gO", c([[call append(line('.')-1, '')]]), { desc = "Insert line above cursor" } },
		{ "n", "gd", cmd.LYRDLSPFindDefinitions },
		{ "n", "gi", cmd.LYRDLSPFindImplementations },
		{ "n", "go", c([[call append(line('.'), '')]]), { desc = "Insert line below cursor" } },
		{ "n", "gr", cmd.LYRDLSPFindReferences },
		{ "n", "gt", cmd.LYRDLSPFindTypeDefinition },
		{ "n", "q", "<nop>" },
		{ "n", "s", "<nop>" },
		{ "v", "<C-r><C-f>", cmd.LYRDCodeRefactor },
		{ "n", "<M-S-f>", cmd.LYRDBufferFormat },
	})

	mappings.create_menu("<Leader>", {
		menu_header("a", "Artificial Intelligence", {
			{ "a", cmd.LYRDAIAssistant, { "x" } },
			{ "k", cmd.LYRDAIAsk, { "x" } },
			{ "e", cmd.LYRDAIEdit },
		}, icons.other.ia, { "x" }),
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
		submode_header("g", "Debug", {
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
		}, icons.file.scratch),
		menu_header("r", "Refactors", {
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
			{ "/", cmd.LYRDSearchBuffers },
			{ ".", cmd.LYRDViewHomePage },
			{ "D", cmd.LYRDLSPShowWorkspaceDiagnosticLocList },
			{ "R", cmd.LYRDViewRegisters },
			{ "d", cmd.LYRDLSPShowDocumentDiagnosticLocList },
			{ "E", cmd.LYRDViewFileExplorerAlt },
			{ "e", cmd.LYRDViewFileExplorer },
			{ "f", cmd.LYRDViewFileTree },
			{ "g", cmd.LYRDDebugToggleUI },
			{ "h", cmd.LYRDBufferSplitH },
			{ "l", cmd.LYRDViewLocationList },
			{ "o", cmd.LYRDViewCodeOutline },
			{ "P", cmd.LYRDViewTreeSitterPlayground },
			{ "q", cmd.LYRDViewQuickFixList },
			{ "t", cmd.LYRDTestSummary },
			{ "T", cmd.LYRDTestOutput },
			{ "v", cmd.LYRDBufferSplitV },
			{ "y", cmd.LYRDViewYankList },
			{ "x", cmd.LYRDTerminalList },
			{ "X", cmd.LYRDTerminal },
		}, icons.action.split_v),
		{ "<Enter>", cmd.LYRDWindowZoom },
		{ "<Space>", cmd.LYRDClearSearchHighlights },
		{ "c", cmd.LYRDBufferClose },
		{ "f", cmd.LYRDBufferFormat },
		{ "j", cmd.LYRDSmartCoder },
		{ "d", cmd.LYRDDiagnosticLinesToggle },
		{ "t", cmd.LYRDApplyNextTheme },
		{ "x", cmd.LYRDCodeRunSelection, { "x" } },
		{ "X", cmd.LYRDCodeRun },
		{ "]", cmd.LYRDBufferNext },
		{ "[", cmd.LYRDBufferPrev },
	})

	mappings.create_menu("<Space>", {
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
			{ "B", cmd.LYRDCodeBuildAll },
			{ "I", cmd.LYRDCodeImplementInterface },
			{ "a", cmd.LYRDLSPFindCodeActions },
			{ "b", cmd.LYRDCodeBuild },
			{ "c", cmd.LYRDCodeGlobalCheck },
			{ "d", cmd.LYRDCodeAddDocumentation },
			{ "e", cmd.LYRDCodeSelectEnvironment },
			{ "f", cmd.LYRDCodeFillStructure },
			{ "i", cmd.LYRDCodeFixImports },
			{ "l", cmd.LYRDDiagnosticLinesToggle },
			{ "m", cmd.LYRDCodeMakeTasks },
			{ "p", cmd.LYRDCodeRestorePackages },
			{ "r", cmd.LYRDCodeRefactor },
			{ "S", cmd.LYRDCodeSecrets },
			{ "t", cmd.LYRDCodeAlternateFile },
			{ "x", cmd.LYRDCodeRun },
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
		menu_header("f", "Find", {
			{ ".", cmd.LYRDSearchFiles },
			{ "b", cmd.LYRDSearchBuffers },
			{ "g", cmd.LYRDSearchGitFiles },
			{ "h", cmd.LYRDSearchRecentFiles },
			{ "l", cmd.LYRDSearchBufferLines },
			{ "c", cmd.LYRDSearchCommandHistory },
			{ "m", cmd.LYRDSearchKeyMappings },
			{ "g", cmd.LYRDSearchBufferTags },
			{ "t", cmd.LYRDTerminalList },
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
				menu_header("r", "Hotfix", {
					{ "s", cmd.LYRDGitFlowHotfixStart },
					{ "f", cmd.LYRDGitFlowHotfixFinish },
					{ "p", cmd.LYRDGitFlowHotfixPublish },
				}),
				{ "D", cmd.LYRDGitCheckoutDev },
				{ "M", cmd.LYRDGitCheckoutMain },
			}),
			menu_header("w", "Worktrees", {
				{ "t", cmd.LYRDGitWorkTreeList },
				{ "n", cmd.LYRDGitWorkTreeCreate },
				{ "e", cmd.LYRDGitWorkTreeCreateExistingBranch },
			}),
			{ "g", cmd.LYRDGitUI },
			{ "s", cmd.LYRDGitStatus },
			{ "c", cmd.LYRDGitCommit },
			{ "P", cmd.LYRDGitPush },
			{ "p", cmd.LYRDGitPull },
			{ "d", cmd.LYRDGitViewDiff },
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
		menu_header("p", "Packages", {
			{ "t", cmd.LYRDToolManager },
			{ "p", cmd.LYRDPluginManager },
			{ "i", cmd.LYRDPluginsInstall },
			{ "u", cmd.LYRDPluginsUpdate },
			{ "c", cmd.LYRDPluginsClean },
		}, icons.other.briefcase),
		menu_header("q", "Quit", {
			{ ".", cmd.LYRDWindowClose },
			{ "q", cmd.LYRDWindowForceCloseAll },
			{ "Q", cmd.LYRDWindowForceCloseAll },
		}, icons.action.exit),
		menu_header("r", "Run", {
			menu_header("r", "REPL", {
				{ "v", cmd.LYRDReplView },
				{ "r", cmd.LYRDReplRestart },
			}, icons.other.command),
		}, icons.code.run),
		menu_header("s", "Services", {
			{ "d", cmd.LYRDDatabaseUI },
			{ "c", cmd.LYRDContainersUI },
			{ "f", cmd.LYRDViewFileExplorer },
			{ "g", cmd.LYRDGitUI },
			{ "k", cmd.LYRDKubernetesUI },
			{ "t", cmd.LYRDTerminal },
			{ "T", cmd.LYRDTerminalList },
		}, icons.other.tools),
		menu_header("u", "User interface", {
			{ "h", cmd.LYRDHardModeToggle },
		}, icons.other.palette),
		menu_header("v", "View", {
			{ ".", cmd.LYRDViewHomePage },
			{ "f", cmd.LYRDViewFocusMode },
			{ "w", cmd.LYRDBufferToggleWrap },
			{ "T", cmd.LYRDApplyCurrentTheme },
			{ "t", cmd.LYRDApplyNextTheme },
		}, icons.action.view),
	})
end

return L
