local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Clipboard Management",
	unskippable = true,
	required_plugins = {
		{
			"gbprod/yanky.nvim",
			opts = {},
		},
	},
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

function L.keybindings()
	vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
	vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
	vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
	vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

	vim.keymap.set("n", "<c-m-j>", "<Plug>(YankyPreviousEntry)")
	vim.keymap.set("n", "<c-m-k>", "<Plug>(YankyNextEntry)")
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
		{ cmd.LYRDPasteFromHistory, ":YankyRingHistory" },
	})
end

return declarative_layer.apply(L)
