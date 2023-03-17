local mappings = require("LYRD.layers.mappings")
local commands = require("LYRD.layers.commands")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "LYRD Keyboard" }

function L.keybindings(s)
	mappings.keys(s, {
		{ "n", "<C-j>", "<C-w>j" },
		{ "n", "<C-k>", "<C-w>k" },
		{ "n", "<C-h>", "<C-w>h" },
		{ "n", "<C-l>", "<C-w>l" },
		{ "n", "s", "<nop>" },
		{ "n", "<F2>", cmd.LYRDViewFileTree },
		{ "n", "<F5>", cmd.LYRDDebugContinue },
		{ "n", "<F9>", cmd.LYRDDebugBreakpoint },
		{ "n", "<F10>", cmd.LYRDDebugStepOver },
		{ "n", "<F11>", cmd.LYRDDebugStepInto },
		{ "n", "<F2>", cmd.LYRDViewFileTree },
		{ "n", "<S-F2>", cmd.LYRDViewFileExplorer },
		{ "n", "<F3>", cmd.LYRDTestSummary },
		{ "n", "<C-s>", cmd.LYRDBufferSave },
		{ "i", "<C-s>", "<Esc>" .. cmd.LYRDBufferSave.name },
		{ "n", "<C-p>", cmd.LYRDSearchFiles },
		{ "n", "<A-Left>", cmd.LYRDBufferPrev },
		{ "n", "<A-Right>", cmd.LYRDBufferNext },
		{ "n", "<C-F4>", cmd.LYRDBufferClose },
		{ "n", "K", cmd.LYRDLSPHoverInfo },
		{ "n", "<C-k>", cmd.LYRDLSPSignatureHelp },
		{ "n", "gd", cmd.LYRDLSPFindDefinitions },
		{ "n", "gD", cmd.LYRDLSPFindDeclaration },
		{ "n", "gt", cmd.LYRDLSPFindTypeDefinition },
		{ "n", "gi", cmd.LYRDLSPFindImplementations },
		{ "n", "gr", cmd.LYRDLSPFindReferences },
		{ "n", "ga", cmd.LYRDLSPFindCodeActions },
		{ "n", "gA", cmd.LYRDLSPFindRangeCodeActions },
		{ "n", "gO", c([[call append(line('.')-1, '')]]) },
		{ "n", "go", c([[call append(line('.'), '')]]) },
		{ "n", [[gpi"]], [[vi""0p]] },
		{ "n", [[gpi']], [[vi'"0p]] },
		{ "n", "<A-PageUp>", cmd.LYRDLSPGotoPrevDiagnostic },
		{ "n", "<A-PageDown>", cmd.LYRDLSPGotoNextDiagnostic },
		{ "n", "<A-Enter>", cmd.LYRDLSPFindCodeActions },
		{ "n", "<C-r><C-r>", cmd.LYRDLSPRename },
		{ "n", "<C-r><C-f>", cmd.LYRDCodeRefactor },
		{ "v", "<C-r><C-f>", cmd.LYRDCodeRefactor },
	})
	mappings.leader(s, {
		{ "n", { "<Space>" }, c("noh"), "Clear search highlights" },
		{ "n", { "." }, cmd.LYRDViewHomePage },
		{ "n", { "b" }, cmd.LYRDBreakLine },
		{ "n", { "s" }, cmd.LYRDBufferSave },
		{ "n", { "c" }, cmd.LYRDBufferClose },
		{ "n", { "C" }, cmd.LYRDBufferCloseAll },
		{ "n", { "h" }, cmd.LYRDBufferSplitH },
		{ "n", { "v" }, cmd.LYRDBufferSplitV },
		{ "n", { "z" }, cmd.LYRDBufferPrev },
		{ "n", { "x" }, cmd.LYRDBufferNext },
		{ "n", { "a" }, cmd.LYRDLSPFindCodeActions },
		{ "n", { "A" }, cmd.LYRDLSPFindRangeCodeActions },
		{ "n", { "f" }, cmd.LYRDBufferFormat },
		{ "n", { "d" }, cmd.LYRDDebugToggleUI },
		{ "n", { "j" }, cmd.LYRDSmartCoder },
		{ "n", { "r", "n" }, cmd.LYRDLSPRename },
		{ "n", { "r", "f" }, cmd.LYRDCodeRefactor },
		{ "v", { "r", "f" }, cmd.LYRDCodeRefactor },
	})
end

return L
