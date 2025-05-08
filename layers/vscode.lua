local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "VsCode Compatibility",
	vscode_compatible = true,
	condition = vim.g.vscode ~= nil,
}

function L.plugins()
	setup.plugin({})
end

function L.preparation() end

local function vscode_action(action, secondary_action)
	return function()
		local vscode = require("vscode")
		vscode.action(action)
		if secondary_action then
			vscode.action(secondary_action)
		end
	end
end

function L.settings()
	vim.g.clipboard = vim.g.vscode_clipboard

	-- Highlight the yanked text
	local ui_highlight_yank_group = vim.api.nvim_create_augroup("ui_highlight_yank_group", {})
	vim.api.nvim_create_autocmd({ "TextYankPost" }, {
		group = ui_highlight_yank_group,
		pattern = "*",
		callback = function()
			vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
		end,
	})

	commands.implement("*", {
		{
			cmd.LYRDViewFileTree,
			vscode_action("workbench.action.toggleSidebarVisibility", "workbench.files.action.focusFilesExplorer"),
		},
		{ cmd.LYRDSearchBuffers, vscode_action("workbench.action.showAllEditors") },
		{ cmd.LYRDSearchLiveGrep, vscode_action("workbench.action.findInFiles") },
		{ cmd.LYRDBufferClose, vscode_action("workbench.action.closeActiveEditor") },
		{ cmd.LYRDBufferCloseAll, vscode_action("workbench.action.closeAllEditors") },
		{ cmd.LYRDBufferNext, vscode_action("workbench.action.nextEditorInGroup") },
		{ cmd.LYRDBufferPrev, vscode_action("workbench.action.previousEditorInGroup") },
		{ cmd.LYRDBufferFormat, vscode_action("editor.action.formatDocument") },
		{ cmd.LYRDLSPFindCodeActions, vscode_action("problems.action.showQuickFixes") },
		{ cmd.LYRDLSPFindReferences, vscode_action("editor.action.goToReferences") },
		{ cmd.LYRDLSPFindRangeCodeActions, vscode_action("editor.action.quickFix") },
		{ cmd.LYRDLSPFindImplementations, vscode_action("editor.action.goToImplementation") },
		{ cmd.LYRDLSPFindDefinitions, vscode_action("editor.action.revealDefinition") },
		{ cmd.LYRDLSPFindDeclaration, vscode_action("editor.action.revealDeclaration") },
		{ cmd.LYRDCodeRefactor, vscode_action("editor.action.refactor") },
		{ cmd.LYRDLSPHoverInfo, vscode_action("editor.action.showHover") },
		{ cmd.LYRDLSPSignatureHelp, vscode_action("editor.action.showHover") },
		{ cmd.LYRDLSPFindTypeDefinition, vscode_action("editor.action.goToTypeDefinition") },
		{ cmd.LYRDLSPRename, vscode_action("editor.action.rename") },
		{ cmd.LYRDViewQuickFixList, vscode_action("problems.action.open") },
		{ cmd.LYRDPaneNavigateLeft, vscode_action("workbench.action.navigateLeft") },
		{ cmd.LYRDPaneNavigateRight, vscode_action("workbench.action.navigateRight") },
		{ cmd.LYRDPaneNavigateUp, vscode_action("workbench.action.navigateUp") },
		{ cmd.LYRDPaneNavigateDown, vscode_action("workbench.action.navigateDown") },
		{ cmd.LYRDBufferSplitH, vscode_action("workbench.action.splitEditorDown") },
		{ cmd.LYRDBufferSplitV, vscode_action("workbench.action.splitEditor") },
	})
end

function L.keybindings() end

function L.complete() end

return L
