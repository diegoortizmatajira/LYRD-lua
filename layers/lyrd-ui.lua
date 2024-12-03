local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

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
							filetype = "neotest-summary",
							text = "Tests",
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
				sections = {
					lualine_c = {
						"filename",
					},
					lualine_x = {
						"tabnine",
						"filetype",
					},
				},
			},
			dependencies = {
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
			"goolord/alpha-nvim",
			config = function()
				local startify = require("alpha.themes.startify")
				startify.section.header.val = header()
				startify.section.top_buttons.val = {
					startify.button("e", icons.file.new .. "  New file", ":ene <BAR> startinsert <CR>"),
					startify.button("p", icons.other.project .. "  Select Project", ":Telescope projects<CR>"),
					startify.button("w", icons.other.workspace .. "  Select Workspaces", ":Telescope workspaces<CR>"),
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
		{
			"natecraddock/workspaces.nvim",
			opts = {
				float_opts = {
					border = "rounded",
					highlights = { border = "Normal", background = "Normal" },
				},
			},
			config = function(opts)
				require("workspaces").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("workspaces")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
		},
		{
			"zeioth/project.nvim",
			opts = {
				detection_methods = {
					"lsp",
					"pattern",
				},
				patterns = {
					".git",
					"_darcs",
					".hg",
					".bzr",
					".svn",
					"Makefile",
					"package.json",
					"pom.xml",
					".solution",
					".solution.toml",
				},
				exclude_dirs = {
					"~/",
				},
				exclude_chdir = {
					filetype = { "", "OverseerList", "alpha" },
					buftype = { "nofile", "terminal" },
				},
			},
			config = function(opts)
				require("project_nvim").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("ui-select")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
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
			"LintaoAmons/scratch.nvim",
			opts = {
				use_telescope = true,
				file_picker = "telescope",

				filetypes = { "lua", "js", "sh", "ts", "json", "yaml", "txt" },
			},
			event = "VeryLazy",
		},
		{
			"diegoortizmatajira/bufdelete.nvim",
			opts = {
				debug = false,
				close_with_their_window = {
					{ filename = "fugitive:" },
					{ filetype = "NvimTree" },
					{ filetype = "alpha" },
					{ filetype = "fugitive" },
					{ filetype = "gitcommit" },
					{ filetype = "help" },
					{ filetype = "http_response" },
					{ filetype = "lazy" },
					{ filetype = "neotest-summary" },
					{ filetype = "trouble" },
				},
			},
		},
		{
			"nvim-pack/nvim-spectre",
			opts = {},
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
		{
			"fasterius/simple-zoom.nvim",
			opts = {
				hide_tabline = false,
			},
		},
	})
end

function L.settings(s)
	-- vim.cmd.colorscheme("gruvbox")
	vim.cmd.colorscheme("catppuccin")
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

	-- Causes alpha to be opened when closing all buffers
	vim.api.nvim_create_augroup("alpha_on_empty", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		pattern = "BDeletePost *",
		group = "alpha_on_empty",
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local name = vim.api.nvim_buf_get_name(bufnr)

			if vim.bo[bufnr].filetype ~= "alpha" and name == "" then
				vim.cmd([[:Alpha | bd#]])
			end
		end,
	})

	commands.implement(s, "*", {
		{ cmd.LYRDViewHomePage, ":Alpha" },
		{ cmd.LYRDScratchNew, ":ScratchWithName" },
		{ cmd.LYRDScratchOpen, ":ScratchOpen" },
		{ cmd.LYRDScratchSearch, ":ScratchOpenFzf" },

		{ cmd.LYRDBufferClose, ":Bdelete" },
		{ cmd.LYRDBufferCloseAll, ":bufdo Bdelete" },
		{ cmd.LYRDBufferForceClose, ":Bdelete!" },
		{ cmd.LYRDWindowZoom, ":SimpleZoomToggle" },

		{
			cmd.LYRDReplace,
			function()
				require("spectre").open_file_search({ select_word = true })
			end,
		},
		{
			cmd.LYRDReplaceInFiles,
			function()
				require("spectre").toggle()
			end,
		},
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
