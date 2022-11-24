local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "LYRD UI" }

function L.plugins(s)
	setup.plugin(s, {
		{ "nvim-lualine/lualine.nvim", requires = "kyazdani42/nvim-web-devicons" },
		"ellisonleao/gruvbox.nvim",
		{ "goolord/alpha-nvim", requires = "kyazdani42/nvim-web-devicons" },
		"rktjmp/lush.nvim",
		"junegunn/vim-peekaboo",
		"kyazdani42/nvim-web-devicons",
	})
end

local function startify_setup()
	local alpha = require("alpha")
	local startify = require("alpha.themes.startify")
	startify.section.header.val = {
		[[   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆           █     █░ ▓█████  ██▓     ▄████▄  ▒█████   ███▄ ▄███▓ ▓█████]],
		[[    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ▓█░ █ ░█░ ▓█   ▀ ▓██▒    ▒██▀ ▀█ ▒██▒  ██▒▓██▒▀█▀ ██▒ ▓█   ▀]],
		[[          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ▒█░ █ ░█  ▒███   ▒██░    ▒▓█    ▄▒██░  ██▒▓██    ▓██░ ▒███  ]],
		[[           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ░█░ █ ░█  ▒▓█  ▄ ▒██░   ▒▒▓▓▄ ▄██▒██   ██░▒██    ▒██  ▒▓█  ▄]],
		[[          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ░░██▒██▓ ▒░▒████▒░██████░▒ ▓███▀ ░ ████▓▒░▒██▒   ░██▒▒░▒████]],
		[[   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ░ ▓░▒ ▒  ░░░ ▒░ ░░ ▒░▓  ░░ ░▒ ▒  ░ ▒░▒░▒░ ░ ▒░   ░  ░░░░ ▒░ ]],
		[[  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄     ▒ ░ ░  ░ ░ ░  ░░ ░ ▒     ░  ▒    ░ ▒ ▒░ ░  ░      ░░ ░ ░  ]],
		[[ ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄    ░   ░      ░     ░ ░   ░       ░ ░ ░ ▒  ░      ░       ░  ]],
		[[ ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄     ░    ░   ░  ░    ░   ░ ░         ░ ░         ░   ░   ░  ]],
		[[      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ]],
		[[       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     LYRD Neovim by Diego Ortiz]],
	}
	startify.section.top_buttons.val = { startify.button("e", "  New file", ":ene <BAR> startinsert <CR>") }
	startify.section.mru.val[2].val = "Files"
	startify.section.mru.val[4].val = function()
		return { startify.mru(10) }
	end
	startify.section.mru_cwd.val[2].val = "Current Directory"
	startify.section.mru_cwd.val[4].val = function()
		return { startify.mru(0, vim.fn.getcwd()) }
	end
	local config = startify.config
	alpha.setup(config)
end

local function devicons_setup()
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
end

function L.settings(s)
	commands.implement(s, "alpha", {
		LYRDBufferSave = [[:echo 'No saving']],
	})
	-- Set theme
	require("gruvbox").setup({ contrast = "hard" })
	vim.cmd([[colorscheme gruvbox]])

	startify_setup()
	require("lualine").setup({ options = { theme = "gruvbox" } })
	devicons_setup()
	-- Highlight the yanked text
	vim.cmd([[
    augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=500}
    augroup END
    ]])
	commands.implement(s, "*", { LYRDViewHomePage = ":Alpha" })
end

return L
