local setup = require("LYRD.setup")
local mappings = require("LYRD.layers.mappings")

local L = { name = "Neovide" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(_)
	if vim.g.neovide then
		vim.g.neovide_refresh_rate = 60
		vim.g.neovide_refresh_rate_idle = 5
		vim.g.neovide_transparency = 1
		vim.g.neovide_cursor_animation_length = 0.008
		vim.g.neovide_cursor_trail_length = 0.15
		vim.g.neovide_cursor_vfx_mode = "railgun"
		vim.g.gui_font_default_size = 12
		vim.g.gui_font_size = vim.g.gui_font_default_size
		vim.g.gui_font_face = "FiraCode Nerd Font"
		L.RefreshGuiFont()
	end
end

function L.keybindings(s)
	if vim.g.neovide then
		mappings.keys(s, {
			{ "n", "<C-+>", ':lua require("LYRD.layers.neovide").ResizeGuiFont(1)' },
			{ "n", "<C-->", ':lua require("LYRD.layers.neovide").ResizeGuiFont(-1)' },
		})
	end
end

function L.complete(s) end

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
