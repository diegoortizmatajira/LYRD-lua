local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.Clipboard: LYRD.setup.Module
local L = {
	name = "Clipboard",
}

--- Returns a function that copies a specific path to the clipboard
-- based on the given Vim expansion string.
-- @param expand_str string: The Vim expansion string used to determine the path.
-- @return function: A function that, when called, copies the expanded path to the clipboard and notifies the user.
local function copy_path(expand_str)
	return function()
		local path = vim.fn.expand(expand_str)
		vim.fn.setreg("+", path)
		vim.notify('Copied "' .. path .. '" to the clipboard!')
	end
end

--- Copies the current working directory to the clipboard and notifies the user.
local function copy_working_directory()
	local path = vim.fn.getcwd()
	vim.fn.setreg("+", path)
	vim.notify('Copied "' .. path .. '" to the clipboard!')
end

function L.settings()
	-- only set clipboard if not in ssh, to make sure the OSC 52
	-- integration works automatically. Requires Neovim >= 0.10.0
	vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
	commands.implement("*", {
		{ cmd.LYRDCopyFileName, copy_path("%:t") },
		{ cmd.LYRDCopyRelativeFilePath, copy_path("%:p:.") },
		{ cmd.LYRDCopyAbsoluteFilePath, copy_path("%:p") },
		{ cmd.LYRDCopyWorkingDirectory, copy_working_directory },
	})
end

return L
