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

local function vscode_action(action)
	return function()
		local vscode = require("vscode")
		vscode.action(action)
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
		{ cmd.LYRDBufferClose, vscode_action("workbench.action.closeActiveEditor") },
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
	})
end

function L.keybindings() end

function L.complete() end

return L
