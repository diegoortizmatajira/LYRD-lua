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

--- Trims leading/trailing whitespace from the clipboard content and writes it back.
local function trim_clipboard()
	local content = vim.fn.getreg("+")
	vim.fn.setreg("+", vim.trim(content))
	vim.notify("Trimmed clipboard content!")
end

--- Removes a wrapping pair of double quotes from the clipboard content, if
--- present, and unescapes CSV-style doubled quotes ("" -> ") within it.
local function unquote_clipboard()
	local content = vim.fn.getreg("+")
	local unquoted = content
	if #unquoted >= 2 and unquoted:sub(1, 1) == '"' and unquoted:sub(-1) == '"' then
		unquoted = unquoted:sub(2, -2)
	end
	unquoted = unquoted:gsub('""', '"')
	vim.fn.setreg("+", unquoted)
	vim.notify("Unquoted clipboard content!")
end

function L.keybindings()
	vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
	vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
	vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
	vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

	vim.keymap.set("n", "<c-m-j>", "<Plug>(YankyPreviousEntry)")
	vim.keymap.set("n", "<c-m-k>", "<Plug>(YankyNextEntry)")
end

--- Checks whether a clipboard tool matching the current display server is available.
---@return boolean
local function has_native_provider()
	if vim.env.WAYLAND_DISPLAY then
		return vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1
	end
	if vim.env.DISPLAY then
		return vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1
	end
	return vim.fn.has("mac") == 1 or vim.fn.has("win32") == 1
end

--- Uses OSC 52 for copying. Terminals commonly block OSC 52 reads, so pasting
--- returns the last yanked content instead of querying the terminal.
local function use_osc52_provider()
	local osc52 = require("vim.ui.clipboard.osc52")
	local cache = { ["+"] = { {}, "v" }, ["*"] = { {}, "v" } }
	local function copy(reg)
		local send = osc52.copy(reg)
		return function(lines, regtype)
			cache[reg] = { lines, regtype }
			send(lines, regtype)
		end
	end
	local function paste(reg)
		return function()
			return cache[reg]
		end
	end
	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = copy("+"), ["*"] = copy("*") },
		paste = { ["+"] = paste("+"), ["*"] = paste("*") },
	}
end

function L.settings()
	if not vim.env.SSH_TTY and not has_native_provider() then
		use_osc52_provider()
	end
	-- only set clipboard if not in ssh, to make sure the OSC 52
	-- integration works automatically. Requires Neovim >= 0.10.0
	vim.o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
	commands.implement("*", {
		{ cmd.LYRDCopyFileName, copy_path("%:t") },
		{ cmd.LYRDCopyRelativeFilePath, copy_path("%:p:.") },
		{ cmd.LYRDCopyAbsoluteFilePath, copy_path("%:p") },
		{ cmd.LYRDCopyWorkingDirectory, copy_working_directory },
		{ cmd.LYRDPasteFromHistory, ":YankyRingHistory" },
		{ cmd.LYRDClipboardTrim, trim_clipboard },
		{ cmd.LYRDClipboardUnquote, unquote_clipboard },
	})
end

return declarative_layer.apply(L)
