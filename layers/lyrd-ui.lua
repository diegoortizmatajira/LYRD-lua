local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "LYRD UI" }

local function combine_ascii_art(base, new, from_line)
	for i = 1, #new, 1 do
		base[from_line + i] = base[from_line + i] .. new[i]
	end
	return base
end

local function header()
	local image = {
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣶⣦⡄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⢀⠀⢹⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣷⣄⠨⣿⣿⣿⡌⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣷⣿⣿⣿⣿⣿⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⣠⣴⣾⣿⣮⣝⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠈⠉⠙⠻⢿⣿⣿⣿⣿⣿⣿⠟⣹⣿⡿⢿⣿⣿⣬⣶⣶⡶⠦⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⠀⣀⣢⣙⣻⢿⣿⣿⣿⠎⢸⣿⠕⢹⣿⣿⡿⣛⣥⣀⣀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⡏⣿⡏⠿⢄⣜⣡⠞⠛⡽⣸⡿⣟⡋⠉⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠾⠿⣿⠁⠀⡄⠀⠀⠰⠾⠿⠛⠓⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠠⢐⢉⢷⣀⠛⠠⠐⠐⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
		[[⠀⠀⠀⠀⣀⣠⣴⣶⣿⣧⣾⠡⠼⠎⢎⣋⡄⠆⠀⠱⡄⢉⠃⣦⡤⡀⠀⠀⠀⠀]],
		[[⠀⠀⠐⠙⠻⢿⣿⣿⣿⣿⣿⣿⣄⡀⠀⢩⠀⢀⠠⠂⢀⡌⠀⣿⡇⠟⠀⠀⢄⠀]],
		[[⠀⣴⣇⠀⡇⠀⠸⣿⣿⣿⣿⣽⣟⣲⡤⠀⣀⣠⣴⡾⠟⠀⠀⠟⠀⠀⠀⠀⡰⡀]],
		[[⣼⣿⠋⢀⣇⢸⡄⢻⣟⠻⣿⣿⣿⣿⣿⣿⠿⡿⠟⢁⠀⠀⠀⠀⠀⢰⠀⣠⠀⠰]],
		[[⢸⣿⡣⣜⣿⣼⣿⣄⠻⡄⡀⠉⠛⠿⠿⠛⣉⡤⠖⣡⣶⠁⠀⠀⠀⣾⣶⣿⠐⡀]],
		[[⣾⡇⠈⠛⠛⠿⣿⣿⣦⠁⠘⢷⣶⣶⡶⠟⢋⣠⣾⡿⠃⠀⠀⠀⠰⠛⠉⠉⠀⠀  LYRD® Neovim by Diego Ortiz. 2023]],
	}
	local title = {
		[[  █     █░ ▓█████  ██▓     ▄████▄  ▒█████   ███▄ ▄███▓ ▓█████]],
		[[ ▓█░ █ ░█░ ▓█   ▀ ▓██▒    ▒██▀ ▀█ ▒██▒  ██▒▓██▒▀█▀ ██▒ ▓█   ▀]],
		[[ ▒█░ █ ░█  ▒███   ▒██░    ▒▓█    ▄▒██░  ██▒▓██    ▓██░ ▒███  ]],
		[[ ░█░ █ ░█  ▒▓█  ▄ ▒██░   ▒▒▓▓▄ ▄██▒██   ██░▒██    ▒██  ▒▓█  ▄]],
		[[ ░░██▒██▓ ▒░▒████▒░██████░▒ ▓███▀ ░ ████▓▒░▒██▒   ░██▒▒░▒████]],
		[[ ░ ▓░▒ ▒  ░░░ ▒░ ░░ ▒░▓  ░░ ░▒ ▒  ░ ▒░▒░▒░ ░ ▒░   ░  ░░░░ ▒░ ]],
		[[   ▒ ░ ░  ░ ░ ░  ░░ ░ ▒     ░  ▒    ░ ▒ ▒░ ░  ░      ░░ ░ ░  ]],
		[[   ░   ░      ░     ░ ░   ░       ░ ░ ░ ▒  ░      ░       ░  ]],
	}
	return combine_ascii_art(image, title, 3)
end

local gruvbox_options = { contrast = "hard" }

local lualine_options = {
	options = { theme = "gruvbox" },
	sections = {
		lualine_c = {
			"filename",
		},
	},
}
local dressing_option = {
	input = {
		-- Set to false to disable the vim.ui.input implementation
		enabled = true,
		prompt_align = "center",
		relative = "editor",
	},
}
local function alpha_options()
	local startify = require("alpha.themes.startify")
	startify.section.header.val = header()
	startify.section.top_buttons.val = { startify.button("e", "  New file", ":ene <BAR> startinsert <CR>") }
	startify.section.mru.val[2].val = "Files"
	startify.section.mru.val[4].val = function()
		return { startify.mru(10) }
	end
	startify.section.mru_cwd.val[2].val = "Current Directory"
	startify.section.mru_cwd.val[4].val = function()
		return { startify.mru(0, vim.fn.getcwd()) }
	end
	startify.file_icons.provider = "devicons"
	return startify.config
end

function L.plugins(s)
	setup.plugin(s, {
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"ellisonleao/gruvbox.nvim",
			priority = 1000,
			opts = gruvbox_options,
		},
		{
			"goolord/alpha-nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		-- { "rktjmp/lush.nvim" },
		{
			"nvim-tree/nvim-web-devicons",
			config = function()
				vim.g.webdevicons_enable = 1
				vim.g.webdevicons_enable_nerdtree = 1
				vim.g.webdevicons_enable_unite = 1
				vim.g.webdevicons_enable_vimfiler = 1
				vim.g.webdevicons_enable_airline_tabline = 1
				vim.g.webdevicons_enable_airline_statusline = 1
				vim.g.webdevicons_enable_ctrlp = 1
				vim.g.webdevicons_enable_flagship_statusline = 1
				vim.g.WebDevIconsUnicodeDecorateFileNodes = 1
				vim.g.WebDevIconsUnicodeGlyphDoubleWidth = 1
				vim.g.webdevicons_conceal_nerdtree_brackets = 1
				vim.g.WebDevIconsNerdTreeAfterGlyphPadding = "  "
				vim.g.WebDevIconsNerdTreeGitPluginForceVAlign = 1
				vim.g.webdevicons_enable_denite = 1
				vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
				vim.g.DevIconsEnableFoldersOpenClose = 1
				vim.g.DevIconsEnableFolderPatternMatching = 1
				vim.g.DevIconsEnableFolderExtensionPatternMatching = 1
				vim.g.WebDevIconsUnicodeDecorateFolderNodesExactMatches = 1
			end,
		},
		{
			"stevearc/dressing.nvim",
			opts = dressing_option,
		},
		{
			"tummetott/unimpaired.nvim",
			event = "VeryLazy",
			opts = {},
		},
	})
end

function L.settings(s)
	vim.o.background = "dark" -- or "light" for light mode
	vim.cmd([[colorscheme gruvbox]])

	require("alpha").setup(alpha_options()) --Required as lazy load doesn't initialize it
	require("lualine").setup(lualine_options) --Required as lazy load doesn't initialize it

	-- The PC is fast enough, do syntax highlight syncing from start unless 200 lines
	local ui_sync_fromstart_group = vim.api.nvim_create_augroup("ui_sync_fromstart", {})
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = ui_sync_fromstart_group,
		pattern = { "*" },
		command = ":syntax sync maxlines=200",
	})

	-- Remember cursor position
	local ui_remember_cursor_position_group = vim.api.nvim_create_augroup("ui_remember_cursor_position", {})
	vim.api.nvim_create_autocmd({ "BufReadPost" }, {
		group = ui_remember_cursor_position_group,
		pattern = { "*" },
		command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]],
	})

	-- Highlight the yanked text
	local ui_highlight_yank_group = vim.api.nvim_create_augroup("ui_highlight_yank_group", {})
	vim.api.nvim_create_autocmd({ "TextYankPost" }, {
		group = ui_highlight_yank_group,
		pattern = "*",
		callback = function()
			vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
		end,
	})

	commands.implement(s, "*", {
		{ cmd.LYRDViewHomePage, ":Alpha" },
	})
	commands.implement(s, "alpha", {
		{ cmd.LYRDBufferSave, [[:echo 'No saving']] },
	})
end

return L
