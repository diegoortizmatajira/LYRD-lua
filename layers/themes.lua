local commands = require("LYRD.layers.commands")
local setup = require("LYRD.shared.setup")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.Themes: LYRD.shared.setup.Module
local L = {
	name = "Color Themes",
	favorite_themes = {
		{
			name = "gruvbox - dark",
			colorscheme = "gruvbox",
			before = [[vim.o.background = "dark"]],
		},
		"bamboo",
		"kanagawa",
		"tokyonight",
		"catppuccin",
		"onedark",
		"monokai-pro",
		"duskfox",
		{
			name = "gruvbox - light",
			colorscheme = "gruvbox",
			before = [[vim.o.background = "light"]],
		},
	},
	globalBefore = [[vim.o.background = "dark"]],
}

function L.notify_current_theme()
	local themery = require("themery")
	local current_theme = themery.getCurrentTheme()
	if current_theme and current_theme.name then
		vim.notify("Theme changed to " .. current_theme.name, vim.log.levels.INFO, { title = "UI" })
	end
end

--Applies the currently selected_theme
function L.apply_theme(skip_notification, index)
	local themery = require("themery")
	if not index then
		local current_theme = themery.getCurrentTheme()
		index = (current_theme and current_theme.index) or 1
	end
	local themes = themery.getAvailableThemes()
	if index > #themes then
		index = 1
	end
	themery.setThemeByIndex(index, true)
	if not skip_notification then
		L.notify_current_theme()
	end
end

-- Rotates through favorite themes
function L.next_theme()
	local themery = require("themery")
	local current_theme = themery.getCurrentTheme()
	local index = (current_theme and current_theme.index) or 1
	L.apply_theme(false, index + 1)
end

function L.plugins()
	setup.plugin({
		{
			"folke/tokyonight.nvim",
			priority = 1000,
			opts = {
				style = "night",
			},
		},
		{
			"ellisonleao/gruvbox.nvim",
			priority = 1000,
			opts = {
				contrast = "hard",
				dim_inactive = false,
			},
		},
		{
			"rebelot/kanagawa.nvim",
			priority = 1000,
			opts = {
				theme = "wave",
			},
		},
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			opts = {
				flavour = "mocha",
			},
		},
		{
			"EdenEast/nightfox.nvim",
			priority = 1000,
			opts = {
				options = {
					styles = {
						comments = "italic",
						keywords = "bold",
						types = "italic,bold",
					},
				},
			},
		},
		{
			"ribru17/bamboo.nvim",
			priority = 1000,
			opts = {
				style = "vulgaris",
			},
		},
		{
			"olimorris/onedarkpro.nvim",
			priority = 1000, -- Ensure it loads first
			opts = {
				theme = "onedark",
				highlights = {
					Comment = { extend = true, italic = true },
				},
			},
		},
		{
			"loctvl842/monokai-pro.nvim",
			lazy = false,
			priority = 1000,
			opts = {},
		},
		{
			"zaldih/themery.nvim",
			opts = {
				themes = L.favorite_themes,
				livePreview = true,
			},
		},
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDSearchColorSchemes, ":Themery" },
		{ cmd.LYRDApplyCurrentTheme, L.apply_theme },
		{ cmd.LYRDApplyNextTheme, L.next_theme },
	})
end

return L
