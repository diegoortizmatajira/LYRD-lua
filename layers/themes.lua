local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "Themes",
	favorite_themes = {
		{
			name = "Gruvbox - Dark",
			colorscheme = "gruvbox",
			before = [[vim.o.background = "dark"]],
		},
		{
			name = "Gruvbox - Light",
			colorscheme = "gruvbox",
			before = [[vim.o.background = "light"]],
		},
		"catppuccin-mocha",
		"catppuccin-frappe",
		"catppuccin-macchiato",
		"catppuccin",
		"carbonfox",
		"nightfox",
		"terafox",
		"duskfox",
		"nordfox",
		"dawnfox",
		"kanagawa-dragon",
		"kanagawa-wave",
		"kanagawa-lotus",
		"bamboo-multiplex",
		"bamboo-vulgaris",
		"tokyonight-storm",
		"tokyonight-night",
		"tokyonight-moon",
		"tokyonight-day",
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

function L.plugins(s)
	setup.plugin(s, {
		{
			"folke/tokyonight.nvim",
			priority = 1000,
			opts = {},
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
			opts = {},
		},
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			opts = {},
		},
		{
			"EdenEast/nightfox.nvim",
			priority = 1000,
			opts = {},
		},
		{
			"ribru17/bamboo.nvim",
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

function L.settings(s)
	commands.implement("*", {
		{ cmd.LYRDSearchColorSchemes, ":Themery" },
		{ cmd.LYRDApplyCurrentTheme, L.apply_theme },
		{ cmd.LYRDApplyNextTheme, L.next_theme },
	})
end

return L
