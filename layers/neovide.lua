local setup = require("LYRD.setup")
local mappings = require("LYRD.layers.mappings")

local L = { name = "Neovide" }

function L.plugins()
	setup.plugin({})
end

function L.settings()
	if vim.g.neovide then
		vim.g.neovide_refresh_rate = 60
		vim.g.neovide_refresh_rate_idle = 5
		vim.g.neovide_transparency = 1
		vim.g.neovide_cursor_animation_length = 0.008
		vim.g.neovide_cursor_trail_length = 0.15
		vim.g.neovide_cursor_vfx_mode = "railgun"
		vim.g.gui_font_default_size = 11
		vim.g.gui_font_size = vim.g.gui_font_default_size
		vim.g.gui_font_face = "Fira Code"
		L.RefreshGuiFont()
	end
end

function L.keybindings()
	if vim.g.neovide then
		mappings.keys({
			{ "n", "<C-+>", ':lua require("LYRD.layers.neovide").ResizeGuiFont(1)<CR>' },
			{ "n", "<C-->", ':lua require("LYRD.layers.neovide").ResizeGuiFont(-1)<CR>' },
		})
	end
end

L.RefreshGuiFont = function()
	vim.opt.guifont = string.format("%s:h%s", vim.g.gui_font_face, vim.g.gui_font_size)
end

L.ResizeGuiFont = function(delta)
	vim.g.gui_font_size = vim.g.gui_font_size + delta
	L.RefreshGuiFont()
end

L.ResetGuiFont = function()
	vim.g.gui_font_size = vim.g.gui_font_default_size
	L.RefreshGuiFont()
end

return L
