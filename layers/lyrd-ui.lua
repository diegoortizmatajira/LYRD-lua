local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "LYRD UI" }
local ext_app_term = nil -- Store the terminal object

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

function L.plugins(s)
	setup.plugin(s, {
		{
			"akinsho/bufferline.nvim",
			version = "*",
			opts = {
				highlights = {
					background = {
						italic = true,
					},
					buffer_selected = {
						bold = true,
						italic = false,
					},
				},
				options = {
					themable = true,
					mode = "buffers",
					numbers = "none",
					show_buffer_close_icons = false,
					separator_style = "slope",
					offsets = {
						{
							filetype = "NvimTree",
							text = "Explorer",
							highlight = "PanelHeading",
							padding = 1,
						},
						{
							filetype = "DiffviewFiles",
							text = "Diff View",
							highlight = "PanelHeading",
							padding = 1,
						},
					},
				},
			},
			dependencies = "nvim-tree/nvim-web-devicons",
		},
		{
			"nvim-lualine/lualine.nvim",
			opts = {
				options = { theme = "gruvbox" },
				sections = {
					lualine_c = {
						"filename",
					},
					lualine_x = {
						"tabnine",
					},
				},
			},
			dependencies = {
				"ellisonleao/gruvbox.nvim",
				"nvim-tree/nvim-web-devicons",
			},
		},
		{
			"ellisonleao/gruvbox.nvim",
			priority = 1000,
			opts = {
				contrast = "hard",
				dim_inactive = true,
			},
			config = function(opts)
				require("gruvbox").setup(opts)
				vim.o.background = "dark" -- or "light" for light mode
				vim.cmd([[colorscheme gruvbox]])
			end,
		},
		{
			"goolord/alpha-nvim",
			config = function()
				local startify = require("alpha.themes.startify")
				startify.section.header.val = header()
				startify.section.top_buttons.val = {
					startify.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
					startify.button("p", "  Select Project", ":Telescope projects<CR>"),
					startify.button("w", "  Select Workspaces", ":Telescope workspaces<CR>"),
				}
				startify.section.mru.val[2].val = "Files"
				startify.section.mru.val[4].val = function()
					return { startify.mru(10) }
				end
				startify.section.mru_cwd.val[2].val = "Current Directory"
				startify.section.mru_cwd.val[4].val = function()
					return { startify.mru(0, vim.fn.getcwd()) }
				end
				startify.file_icons.provider = "devicons"
				require("alpha").setup(startify.config)
			end,
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
		},
		{ "akinsho/toggleterm.nvim" },
		-- { "rktjmp/lush.nvim" },
		{
			"natecraddock/workspaces.nvim",
			opts = {},
			config = function(opts)
				require("workspaces").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("workspaces")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"ahmedkhalf/project.nvim",
			opts = {
				detection_methods = { "lsp", "pattern" },
				patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pom.xml" },
			},
			config = function(opts)
				require("project_nvim").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("ui-select")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
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
			opts = {
				input = {
					-- Set to false to disable the vim.ui.input implementation
					enabled = true,
					prompt_align = "center",
					relative = "editor",
				},
			},
		},
		{
			"tummetott/unimpaired.nvim",
			event = "VeryLazy",
			opts = {},
		},
	})
end

function L.settings(s)
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

function L.toggle_external_app_terminal(external_cmd)
	local Terminal = require("toggleterm.terminal").Terminal
	if ext_app_term and ext_app_term:is_open() then
		ext_app_term:close()
		ext_app_term = nil
	else
		-- Create a floating terminal pane and run a custom command
		ext_app_term = Terminal:new({
			cmd = external_cmd,
			direction = "float",
			float_opts = { border = "double" },
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
			end,
		})
		return ext_app_term:toggle()
	end
end

return L
