local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = {
	name = "LYRD UI",
}

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

function L.notify(message, level, options)
	local notify = require("notify")
	notify(message, level, options)
end

function L.plugins()
	setup.plugin({
		{
			"folke/noice.nvim",
			event = "VeryLazy",
			opts = {
				cmdline = {
					format = {
						cmdline = { icon = icons.other.command },
						search_down = { icon = icons.search.default .. icons.chevron.double_down },
						search_up = { icon = icons.search.default .. icons.chevron.double_up },
						filter = { icon = icons.other.filter },
						lua = { icon = "" },
						help = { icon = icons.other.help },
						input = { icon = icons.other.keyboard }, -- Used by input()
					},
				},
				lsp = {
					progress = {
						enabled = false, -- disables a lot of distracting text from popping up when done
						format_done = "",
					},
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = false, -- use a classic bottom cmdline for search
					command_palette = false, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			},
			config = function(_, opts)
				require("noice").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("noice")
			end,
			dependencies = {
				-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
				"muniftanjim/nui.nvim",
				-- OPTIONAL:
				--   `nvim-notify` is only needed, if you want to use the notification view.
				--   If not available, we use `mini` as the fallback
				"rcarriga/nvim-notify",
			},
		},
		{
			"rcarriga/nvim-notify",
			opts = {
				render = "compact",
				background_colour = "#000000",
				top_down = false,
			},
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
				tabline = {
					lualine_a = { "buffers" },
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { "tabs" },
				},
			},
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
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
				startify.section.mru_cwd.val[2].val = function()
					return "Current Directory"
				end
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
		{
			"akinsho/toggleterm.nvim",
			opts = {},
			cmd = { "ToggleTerm", "TermSelect" },
			lazy = true,
		},
		{
			"natecraddock/workspaces.nvim",
			opts = {
				float_opts = {
					border = "rounded",
					highlights = { border = "Normal", background = "Normal" },
				},
			},
			config = function(_, opts)
				require("workspaces").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("workspaces")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
			lazy = true,
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
			config = function(_, opts)
				require("project_nvim").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("ui-select")
			end,
			dependencies = { "nvim-telescope/telescope.nvim" },
			lazy = true,
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
			"nvim-pack/nvim-spectre",
			opts = {},
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
		{
			"folke/twilight.nvim",
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
			cmd = { "Twilight" },
		},
	})
end

function L.settings()
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

	commands.implement("*", {
		{ cmd.LYRDViewHomePage, ":Alpha" },
		{ cmd.LYRDScratchNew, ":ScratchWithName" },
		{ cmd.LYRDScratchOpen, ":ScratchOpen" },
		{ cmd.LYRDScratchSearch, ":ScratchOpenFzf" },
		{ cmd.LYRDViewFocusMode, ":Twilight" },
		{ cmd.LYRDTerminal, ":ToggleTerm" },
		{ cmd.LYRDTerminalList, ":TermSelect" },
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
