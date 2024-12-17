local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
	name = "Themes",
	favorite_themes = {
		"gruvbox",
		"catppuccin-mocha",
		"catppuccin-frappe",
		"catppuccin-macchiato",
		"catppuccin",
		"carbonfox",
		"nightfox",
		"terafox",
		"duskfox",
		"nordfox",
		"kanagawa-dragon",
		"kanagawa-wave",
		"bamboo-multiplex",
		"bamboo-vulgaris",
		"tokyonight-storm",
		"tokyonight-night",
		"tokyonight-moon",
		"jellybeans",
	},
	selected_theme = 1,
}

--Applies the currently selected_theme
function L.apply_theme(skip_notification)
	local theme = L.favorite_themes[L.selected_theme]
	require("themery").setThemeByName(theme, true)
	-- vim.cmd.colorscheme(theme)
	if skip_notification then
		return
	end
	vim.notify("Theme changed to " .. theme, "info", { title = "UI" })
end

-- Rotates through favorite themes
function L.next_theme()
	L.selected_theme = L.selected_theme + 1
	if L.selected_theme > #L.favorite_themes then
		L.selected_theme = 1
	end
	L.apply_theme()
end

function L.plugins(s)
	setup.plugin(s, {
		{
			"WTFox/jellybeans.nvim",
			priority = 1000,
			opts = {},
		},
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
	commands.implement(s, "*", {
		{ cmd.LYRDSearchColorSchemes, ":Themery" },
		{ cmd.LYRDApplyCurrentTheme, L.apply_theme },
		{ cmd.LYRDApplyNextTheme, L.next_theme },
	})
end

return L
