# LYRD Commands Reference

This document provides a comprehensive list of all LYRD commands with their descriptions, keybindings, and the filetypes where they are implemented.

## Command Table

| Command Name                          | Description                             | Keybindings                                            | Filetypes             |
| ------------------------------------- | --------------------------------------- | ------------------------------------------------------ | --------------------- |
| LYRDAIAsk                             | Ask AI                                  | <Leader>ak                                             | \*                    |
| LYRDAIAssistant                       | AI Assistant                            | <Leader>aa                                             | \*                    |
| LYRDAICli                             | AI Cli tools                            | <Leader>ac                                             | \*                    |
| LYRDAIEdit                            | Edit with AI                            | <Leader>ae                                             | \*                    |
| LYRDAIGenerateDocumentation           | Document current element with AI        | <Leader>ad                                             | \*                    |
| LYRDApplyCurrentTheme                 | Apply current theme                     | <Space>vT                                              | \*                    |
| LYRDApplyNextTheme                    | Apply next favorite theme               | <Leader>.t<br><Space>vt                                | \*                    |
| LYRDBufferClose                       | Close buffer                            | <Leader>.c<br><Space>bd                                | \*<br>http            |
| LYRDBufferCloseAll                    | Close all buffers                       | <Space>bx                                              | \*                    |
| LYRDBufferCopy                        | Copy whole buffer to clipboard          | <Space>bY                                              | default               |
| LYRDBufferForceClose                  | Force close buffer                      | <Space>bD                                              | \*                    |
| LYRDBufferForceCloseAll               | Force close all buffers                 | <Space>bX                                              | default               |
| LYRDBufferFormat                      | Format document                         | <Leader>.f<br><M-S-f><br><Space>bf                     | \*<br>go              |
| LYRDBufferJumpToLast                  | Jump to last buffer                     | -                                                      | default               |
| LYRDBufferNew                         | New empty buffer                        | <Space>be                                              | default               |
| LYRDBufferNext                        | Next buffer                             | <Leader>.]<br><M-C-]><br><Space>bn<br>]b               | \*                    |
| LYRDBufferPaste                       | Paste clipboard to whole buffer         | <Space>bP                                              | default               |
| LYRDBufferPrev                        | Previous Buffer                         | <Leader>.[<br><M-C-[><br><Space>bp<br>[b               | \*                    |
| LYRDBufferSave                        | Save current file                       | <C-s><br><Space>bs                                     | default               |
| LYRDBufferSaveAll                     | Save all files                          | <Space>bS                                              | default               |
| LYRDBufferSetReadOnly                 | Toggle read only mode                   | <Space>bw                                              | default               |
| LYRDBufferSplitH                      | Horizonal split                         | <Leader>.<Leader>h<br><Space>bh                        | \*                    |
| LYRDBufferSplitV                      | Vertical split                          | <Leader>.<Leader>v<br><Space>bv                        | \*                    |
| LYRDBufferToggleWrap                  | Toggle line wrap                        | <M-z><br><Space>vw                                     | default               |
| LYRDClearSearchHighlights             | Clear search highlights                 | <Leader>.<Space>                                       | default               |
| LYRDCodeAddDocumentation              | Add documentation                       | <Space>cd                                              | default               |
| LYRDCodeAlternateFile                 | Toggle alternate file                   | <Space>ct                                              | go                    |
| LYRDCodeBuild                         | Build                                   | <C-M-b><br><Space>cB                                   | go                    |
| LYRDCodeBuildAll                      | Build all                               | <C-B><br><Space>cb                                     | java                  |
| LYRDCodeCreateSnippet                 | Create snippet                          | <Space>csc                                             | \*                    |
| LYRDCodeEditSnippet                   | Edit snippet                            | <Space>cse                                             | \*                    |
| LYRDCodeFillStructure                 | Fill structure                          | <Space>cf                                              | go                    |
| LYRDCodeFixImports                    | Fix imports                             | <Space>ci                                              | go<br>python          |
| LYRDCodeGenerate                      | Run Generator Tool                      | <Space>cgx                                             | go                    |
| LYRDCodeGlobalCheck                   | Global check                            | <Space>cC                                              | go                    |
| LYRDCodeImplementInterface            | Implement interface                     | <Space>cI                                              | go                    |
| LYRDCodeInsertSnippet                 | Insert snippet                          | <Space>csi                                             | \*                    |
| LYRDCodeProduceGetter                 | Generate getters code                   | <Space>cgg                                             | go                    |
| LYRDCodeProduceMapping                | Generate mappings code                  | <Space>cgm                                             | go                    |
| LYRDCodeProduceSetter                 | Generate setters code                   | <Space>cgs                                             | go                    |
| LYRDCodeQuerySelection                | Run selected query                      | <Leader>.y                                             | sql                   |
| LYRDCodeRefactor                      | Refactor                                | <C-r><C-f><br><Leader>rf<br><Space>cr                  | \*                    |
| LYRDCodeRestorePackages               | Restore packages                        | <Space>cp                                              | default               |
| LYRDCodeRun                           | Run                                     | <Leader>.X<br><Space>cx                                | go<br>http<br>sql     |
| LYRDCodeRunSelection                  | Run selection code                      | <Leader>.x<br><S-CR>                                   | http<br>python<br>sql |
| LYRDCodeSecrets                       | Edit Secrets                            | <Space>cS                                              | python                |
| LYRDCodeSelectEnvironment             | Select environment                      | <Space>ce                                              | http<br>python        |
| LYRDCodeTooling                       | Tooling                                 | <Space>cc                                              | python                |
| LYRDContainersUI                      | Running containers UI                   | <Space><SPACE>c                                        | \*                    |
| LYRDDatabaseOutput                    | Database Output                         | <Leader>.<Leader>b                                     | \*                    |
| LYRDDatabaseUI                        | Database UI                             | <Leader>.<Leader>s<br><Space><SPACE>d                  | \*                    |
| LYRDDebugBreakpoint                   | Toggle breakpoint                       | <F9><br><Leader>gb<br><Space>db                        | \*                    |
| LYRDDebugContinue                     | Continue                                | <F5><br><Leader>gd<br><Space>dk                        | \*                    |
| LYRDDebugStart                        | Start debug session                     | <Leader>gg<br><S-F5><br><Space>dy                      | \*                    |
| LYRDDebugStepInto                     | Step into                               | <F11><br><Leader>gv<br><Space>dj                       | \*                    |
| LYRDDebugStepOut                      | Step out                                | <F12><br><Leader>gr<br><Space>du                       | \*                    |
| LYRDDebugStepOver                     | Step over                               | <F10><br><Leader>gf<br><Space>dl                       | \*                    |
| LYRDDebugStop                         | Stop                                    | <Leader>ge<br><Space>dh                                | \*                    |
| LYRDDebugToggleRepl                   | Toggle Debug Repl                       | <Space>d/                                              | \*                    |
| LYRDDebugToggleUI                     | Debug UI                                | <Leader>.<Leader>g<br><Space>d;                        | \*                    |
| LYRDDiagnosticLinesToggle             | Toggle diagnostic lines                 | <Leader>.d<br><Space>cl                                | \*                    |
| LYRDEditLocalConfig                   | Edit local config                       | <Space>pl                                              | default               |
| LYRDGitBrowseOnWeb                    | Browse line on web                      | <Space>gx                                              | \*                    |
| LYRDGitCheckoutDev                    | Checkout Develop branch                 | <Space>gfD                                             | \*                    |
| LYRDGitCheckoutMain                   | Checkout Main branch                    | <Space>gfM                                             | \*                    |
| LYRDGitCommit                         | Commit changes                          | <Space>gc                                              | \*                    |
| LYRDGitFlowFeatureFinish              | Feature finish                          | <Space>gfff                                            | \*                    |
| LYRDGitFlowFeaturePublish             | Feature publish (pull req.)             | <Space>gffp                                            | \*                    |
| LYRDGitFlowFeatureStart               | Feature start                           | <Space>gffs                                            | \*                    |
| LYRDGitFlowHotfixFinish               | Hotfix finish                           | <Space>gfhf                                            | \*                    |
| LYRDGitFlowHotfixPublish              | Hotfix publish (pull req.)              | <Space>gfhp                                            | \*                    |
| LYRDGitFlowHotfixStart                | Hotfix start                            | <Space>gfhs                                            | \*                    |
| LYRDGitFlowInit                       | Init                                    | <Space>gfi                                             | \*                    |
| LYRDGitFlowReleaseFinish              | Release finish                          | <Space>gfrf                                            | \*                    |
| LYRDGitFlowReleasePublish             | Release publish (pull req.)             | <Space>gfrp                                            | \*                    |
| LYRDGitFlowReleaseStart               | Release start                           | <Space>gfrs                                            | \*                    |
| LYRDGitPull                           | Pull                                    | <Space>gp                                              | \*                    |
| LYRDGitPush                           | Push                                    | <Space>gP                                              | \*                    |
| LYRDGitStageAll                       | Stage all                               | <Space>ga                                              | \*                    |
| LYRDGitStatus                         | Status                                  | <Space>gs                                              | \*                    |
| LYRDGitUI                             | Git UI                                  | <Space><SPACE>g<br><Space>gg                           | \*                    |
| LYRDGitViewBlame                      | View blame                              | <Space>gb                                              | default               |
| LYRDGitViewCurrentFileLog             | Current file log                        | <Space>gl                                              | \*                    |
| LYRDGitViewDiff                       | View diff                               | <Space>gd                                              | \*                    |
| LYRDGitViewLog                        | File log                                | -                                                      | default               |
| LYRDGitWorkTreeCreate                 | Create Worktree                         | <Space>gwn                                             | \*                    |
| LYRDGitWorkTreeCreateExistingBranch   | Create Worktree for existing branch     | <Space>gwe                                             | \*                    |
| LYRDGitWorkTreeList                   | List GIT Worktrees                      | <Space>gwt                                             | \*                    |
| LYRDGitWrite                          | Write                                   | -                                                      | default               |
| LYRDHardModeToggle                    | Toggle hard mode                        | <Space>uh                                              | \*                    |
| LYRDInsertImage                       | Insert image                            | <Leader>ii                                             | default               |
| LYRDKubernetesUI                      | Kubernetes UI                           | <Space><SPACE>k                                        | \*                    |
| LYRDLSPFindCodeActions                | Actions                                 | <C-.><br><M-Enter><br><Space>ca                        | \*                    |
| LYRDLSPFindDeclaration                | Go to Declaration                       | gD                                                     | \*                    |
| LYRDLSPFindDefinitions                | Go to Definition                        | gd                                                     | \*                    |
| LYRDLSPFindDocumentDiagnostics        | Find Document Diagnostics               | -                                                      | \*                    |
| LYRDLSPFindDocumentSymbols            | Find Document Symbols                   | -                                                      | \*                    |
| LYRDLSPFindImplementations            | Find Implementations                    | gi                                                     | \*                    |
| LYRDLSPFindLineDiagnostics            | Find Line Diagnostics                   | -                                                      | \*                    |
| LYRDLSPFindRangeCodeActions           | Range Actions                           | <Space>cA                                              | \*                    |
| LYRDLSPFindReferences                 | Find References                         | gr                                                     | \*                    |
| LYRDLSPFindTypeDefinition             | Go to Type Definition                   | gt                                                     | \*                    |
| LYRDLSPFindWorkspaceDiagnostics       | Find Workspace Diagnostics              | -                                                      | \*                    |
| LYRDLSPFindWorkspaceSymbols           | Find Workspace Symbols                  | -                                                      | \*                    |
| LYRDLSPGotoNextDiagnostic             | Goto Next Diagnostic                    | <M-PageDown>                                           | \*                    |
| LYRDLSPGotoPrevDiagnostic             | Goto Previous Diagnostic                | <M-PageUp>                                             | \*                    |
| LYRDLSPHoverInfo                      | Show hover information                  | K                                                      | \*                    |
| LYRDLSPRename                         | Rename symbol                           | <C-r><C-r><br><Leader>rn                               | \*                    |
| LYRDLSPShowDocumentDiagnosticLocList  | Document diagnostics                    | <Leader>.<Leader>d                                     | \*                    |
| LYRDLSPShowWorkspaceDiagnosticLocList | Workspace diagnostics                   | <Leader>.<Leader>D                                     | \*                    |
| LYRDLSPSignatureHelp                  | Signature help                          | <C-S-k>                                                | \*                    |
| LYRDLSPToggleLens                     | Toggle Code Lens                        | -                                                      | \*                    |
| LYRDPaneNavigateDown                  | Navigate to panel below                 | <C-j>                                                  | \*                    |
| LYRDPaneNavigateLeft                  | Navigate to panel left                  | <C-h>                                                  | \*                    |
| LYRDPaneNavigateRight                 | Navigate to panel right                 | <C-l>                                                  | \*                    |
| LYRDPaneNavigateUp                    | Navigate to panel up                    | <C-k>                                                  | \*                    |
| LYRDPaneResizeDown                    | Resize to panel below                   | <Leader>.<Leader>rj                                    | \*                    |
| LYRDPaneResizeLeft                    | Resize to panel left                    | <Leader>.<Leader>rh                                    | \*                    |
| LYRDPaneResizeRight                   | Resize to panel right                   | <Leader>.<Leader>rl                                    | \*                    |
| LYRDPaneResizeUp                      | Resize to panel up                      | <Leader>.<Leader>rk                                    | \*                    |
| LYRDPaneSwapDown                      | Swap to panel below                     | <Leader>.<Leader>sj                                    | \*                    |
| LYRDPaneSwapLeft                      | Swap to panel left                      | <Leader>.<Leader>sh                                    | \*                    |
| LYRDPaneSwapRight                     | Swap to panel right                     | <Leader>.<Leader>sl                                    | \*                    |
| LYRDPaneSwapUp                        | Swap to panel up                        | <Leader>.<Leader>sk                                    | \*                    |
| LYRDPasteImage                        | Paste image                             | <Leader>ip                                             | default               |
| LYRDPluginManager                     | Plugin Manager                          | <Space>pp                                              | default               |
| LYRDPluginsClean                      | Clean plugins                           | <Space>pc                                              | default               |
| LYRDPluginsInstall                    | Install plugins                         | <Space>pi                                              | default               |
| LYRDPluginsUpdate                     | Update plugins                          | <Space>pu                                              | default               |
| LYRDReplNotebookAddCellAbove          | Add notebook cell above                 | <Leader>na<br><Space>cna                               | default               |
| LYRDReplNotebookAddCellBelow          | Add notebook cell below                 | <Leader>nb<br><Space>cnb                               | default               |
| LYRDReplNotebookMoveCellDown          | Move current notebook cell down         | <Leader>nmd<br><Space>cnmd                             | default               |
| LYRDReplNotebookMoveCellUp            | Move current notebook cell up           | <Leader>nmu<br><Space>cnmu                             | default               |
| LYRDReplNotebookRunAllAbove           | Run notebook cells above                | <Leader>nra<br><Space>cnra                             | default               |
| LYRDReplNotebookRunAllBelow           | Run notebook cells below                | <Leader>nrb<br><Space>cnrb                             | default               |
| LYRDReplNotebookRunAllCells           | Run all notebook cells                  | <Leader>nre<br><Space>cnre                             | default               |
| LYRDReplNotebookRunCell               | Run notebook cell                       | <Leader>nrX<br><Space>cnrX                             | default               |
| LYRDReplNotebookRunCellAndMove        | Run notebook cell and move to the next. | <Leader>nrx<br><Leader>nx<br><Space>cnrx<br><Space>cnx | default               |
| LYRDReplRestart                       | REPL Restart                            | <Leader>n<BS><br><Space>cn<BS><br><Space>rRr           | iron                  |
| LYRDReplView                          | View REPL                               | <Leader>nn<br><Space>cnn<br><Space>rRv                 | iron                  |
| LYRDReplace                           | Search and replace in current file      | <Space>sr                                              | \*                    |
| LYRDReplaceInFiles                    | Search and replace in files             | <Space>sR                                              | \*                    |
| LYRDResumeLastSearch                  | Resume last search                      | <C-f>                                                  | \*                    |
| LYRDScratchDelete                     | Delete an scratch file                  | <Leader>sd                                             | \*                    |
| LYRDScratchNew                        | Create a new scratch                    | <Leader>sn                                             | \*                    |
| LYRDScratchOpen                       | Select scratch file to open             | <Leader>ss                                             | \*                    |
| LYRDScratchSearch                     | Search inside scratches                 | <Leader>sf                                             | \*                    |
| LYRDSearchAllFiles                    | Find all files                          | <C-S-p><br><M-C-p>                                     | \*                    |
| LYRDSearchBufferLines                 | Lines                                   | <Space>sl                                              | \*                    |
| LYRDSearchBufferTags                  | Tags                                    | <Space>sg                                              | \*                    |
| LYRDSearchBuffers                     | Search buffers                          | <Leader>.<Leader>/<br><Space>b/<br><Space>sb           | \*                    |
| LYRDSearchColorSchemes                | Color Schemes                           | <Space>st                                              | \*                    |
| LYRDSearchCommandHistory              | Recent comands                          | <Space>sc                                              | \*                    |
| LYRDSearchCommands                    | Commands                                | <Space>s,                                              | \*                    |
| LYRDSearchCurrentString               | Current string in files                 | <Space>sS                                              | \*                    |
| LYRDSearchFiles                       | Find files                              | <C-p><br><Space>s.                                     | \*                    |
| LYRDSearchFiletypes                   | Filetypes                               | <Space>sf                                              | \*                    |
| LYRDSearchGitFiles                    | Git Files                               | <Space>sg                                              | \*                    |
| LYRDSearchHighlights                  | Highlights                              | <Space>sH                                              | \*                    |
| LYRDSearchKeyMappings                 | Key Maps                                | <Space>sm                                              | \*                    |
| LYRDSearchLiveGrep                    | Live grep                               | <C-t><br><Space>s/                                     | \*                    |
| LYRDSearchMacros                      | Macros                                  | <Space>sm                                              | \*                    |
| LYRDSearchQuickFixes                  | Quick Fixes                             | <Space>sq                                              | \*                    |
| LYRDSearchRecentFiles                 | Recent files                            | <Space>sh                                              | \*                    |
| LYRDSearchRegisters                   | Registers                               | <Space>sp                                              | \*                    |
| LYRDSearchSnippets                    | Snippets                                | <Space>ss                                              | \*                    |
| LYRDSearchSymbols                     | Symbols                                 | <Space>so                                              | \*                    |
| LYRDSmartCoder                        | Smart code generator                    | <Leader>.j                                             | \*                    |
| LYRDTasksConfigure                    | Configure tasks                         | <Space>rT                                              | \*                    |
| LYRDTasksConfigureLaunch              | Configure launch profile                | <Space>rL                                              | \*                    |
| LYRDTasksRun                          | Run task                                | <Space>rr                                              | \*                    |
| LYRDTasksToggle                       | Toggle tasks view                       | <Leader>.<Leader>w<br><Space>rt                        | \*                    |
| LYRDTerminal                          | Terminal                                | <Leader>.<Leader>X<br><Space><SPACE>t                  | \*                    |
| LYRDTerminalList                      | View terminal list                      | <Leader>.<Leader>x<br><Space><SPACE>T<br><Space>sT     | \*                    |
| LYRDTest                              | Test everything                         | <Space>tt                                              | \*<br>go              |
| LYRDTestCoverage                      | Toggle Test Coverage                    | <Space>tc                                              | \*<br>go              |
| LYRDTestCoverageSummary               | View Test Coverage Summary              | <Space>ts                                              | \*                    |
| LYRDTestDebugFunc                     | Debug current test function             | <Space>tF                                              | \*                    |
| LYRDTestFile                          | Test current file                       | <Space>tb                                              | \*                    |
| LYRDTestFunc                          | Test current function                   | <Space>tf                                              | \*                    |
| LYRDTestLast                          | Repeat last test                        | <Space>th                                              | \*                    |
| LYRDTestOutput                        | View test output                        | <Leader>.<Leader>T                                     | \*                    |
| LYRDTestSuite                         | Test suite                              | <Space>ts                                              | \*                    |
| LYRDTestSummary                       | View test summary                       | <F3><br><Leader>.<Leader>t<br><Space>tv                | \*                    |
| LYRDToggleBufferDecorations           | Toggle buffer decorations               | <Leader>.k                                             | csv<br>markdown       |
| LYRDToolManager                       | Tool Manager                            | <Space>pt                                              | \*                    |
| LYRDViewCodeOutline                   | View code outline                       | <F4><br><Leader>.<Leader>o                             | \*                    |
| LYRDViewFileExplorer                  | File Explorer                           | <Leader>.<Leader>e<br><Space><SPACE>f                  | \*                    |
| LYRDViewFileExplorerAlt               | File Explorer (Alternative)             | <Leader>.<Leader>E<br><Space><SPACE>F                  | \*                    |
| LYRDViewFileTree                      | File Tree                               | <F2><br><Leader>.<Leader>f                             | \*                    |
| LYRDViewFocusMode                     | Focus mode                              | <Space>vf                                              | \*                    |
| LYRDViewHomePage                      | Home page                               | <Leader>.<Leader>.<br><Space>v.                        | \*                    |
| LYRDViewLocationList                  | Location list                           | <Leader>.<Leader>l                                     | \*                    |
| LYRDViewQuickFixList                  | QuickFix                                | <Leader>.<Leader>q                                     | \*                    |
| LYRDViewRegisters                     | Registers                               | <Leader>.<Leader>R                                     | default               |
| LYRDViewTreeSitterPlayground          | TreeSitter playground                   | <Leader>.<Leader>P                                     | \*                    |
| LYRDViewYankList                      | Yank list                               | <Leader>.<Leader>y                                     | default               |
| LYRDWindowClose                       | Close window                            | <Space>q.                                              | default               |
| LYRDWindowCloseAll                    | Close all                               | -                                                      | default               |
| LYRDWindowForceCloseAll               | Force Quit                              | <Space>qQ<br><Space>qq                                 | default               |
| LYRDWindowZoom                        | Toggles zoom in the selected window     | <Leader>.<Enter>                                       | \*                    |

## Notes

- **Command Name**: The unique identifier for each LYRD command
- **Description**: What the command does
- **Keybindings**: The keyboard shortcuts mapped to this command (multiple
  bindings separated by `<br>`)
  - `<Leader>` is typically mapped to the `,` key
  - `<Space>` is the space bar
  - `<C-x>` represents Ctrl+x
  - `<M-x>` represents Alt+x (Meta key)
  - `<S-x>` represents Shift+x
- **Filetypes**: Where the command is implemented
  - `*` means the command is available globally (all filetypes)
  - `default` means the command has a default implementation but no
    filetype-specific versions
  - Specific filetypes (like `go`, `python`, `markdown`, etc.) indicate
    language-specific implementations

## Command Categories

The commands are organized into several categories:

- **AI Commands** (`LYRDAI*`): AI-powered features and assistants
- **Buffer Commands** (`LYRDBuffer*`): Buffer management and operations
- **Code Commands** (`LYRDCode*`): Code-specific operations (build, run,
  refactor, etc.)
- **Debug Commands** (`LYRDDebug*`): Debugging operations
- **Git Commands** (`LYRDGit*`): Git and version control operations
- **LSP Commands** (`LYRDLSP*`): Language Server Protocol features
- **Search Commands** (`LYRDSearch*`): Various search and navigation operations
- **Test Commands** (`LYRDTest*`): Testing operations
- **View Commands** (`LYRDView*`): UI and view management
- **Window/Pane Commands** (`LYRDWindow*`, `LYRDPane*`): Window and pane
  navigation and management
