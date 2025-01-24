local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

---@class LYRD.ui.special_type
---@field type_id string
---@field title? string
---@field keep_window? boolean
---@field allow_saving? boolean
---@field allow_replacement? boolean

local L = {
	name = "LYRD UI",
	---@type LYRD.ui.special_type[]
	special_filetypes = {
		-- You can add entries here to mark special filetypes that have a header in their
		-- sidebar or that should close with their window (unless the value true is provided)
		{ type_id = "DiffviewFiles", title = "Diff View" },
		{ type_id = "NvimTree", title = "Explorer" },
		{ type_id = "aerial", title = "Outline" },
		{ type_id = "alpha" },
		{ type_id = "fugitive" },
		{ type_id = "noice" },
		{ type_id = "qf" },
		{ type_id = "gitcommit" },
		{ type_id = "help" },
		{ type_id = "http_response" },
		{ type_id = "lazy" },
		{ type_id = "dbui", title = "Database" },
		{ type_id = "dbout" },
		{ type_id = "neotest-summary", title = "Tests" },
		{ type_id = "toggleterm" },
		{ type_id = "OverseerList" },
		{ type_id = "trouble" },
		{ type_id = "tsplayground", title = "Treesitter Playground" },
	},
	special_buffertypes = {
		{ type_id = "terminal" },
	},
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

-- Gets the list of buffers that will have a title in their sidebar
local function get_buffer_offsets()
	local result = {}
	for _, value in pairs(L.special_filetypes) do
		if value.title then
			table.insert(result, {
				filetype = value.type_id,
				text = value.title,
				highlight = "PanelHeading",
				padding = 1,
			})
		end
	end
	return result
end

-- Gets the list of buffers that will be closed when the buffer is closed
local function get_buffers_that_close_with_their_window()
	local result = {
		{ filename = "fugitive:" },
	}
	for _, value in pairs(L.special_filetypes) do
		if not value.keep_window then
			table.insert(result, { filetype = value.type_id })
		end
	end
	for _, value in pairs(L.special_buffertypes) do
		if not value.keep_window then
			table.insert(result, { buftype = value.type_id })
		end
	end
	return result
end

function L.plugins(s)
	setup.plugin(s, {
		{
			"mcauley-penney/visual-whitespace.nvim",
			config = true,
		},
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
				"MunifTanjim/nui.nvim",
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
			"akinsho/bufferline.nvim",
			-- version = "*",
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
					mode = "buffers",
					numbers = "none",
					show_buffer_close_icons = false,
					offsets = get_buffer_offsets(),
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
			"diegoortizmatajira/bufdelete.nvim",
			opts = {
				debug = false,
				close_with_their_window = get_buffers_that_close_with_their_window(),
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

	commands.implement("*", {
		{ cmd.LYRDViewHomePage, ":Alpha" },
		{ cmd.LYRDScratchNew, ":ScratchWithName" },
		{ cmd.LYRDScratchOpen, ":ScratchOpen" },
		{ cmd.LYRDScratchSearch, ":ScratchOpenFzf" },
		{ cmd.LYRDBufferClose, ":Bdelete" },
		{ cmd.LYRDBufferCloseAll, ":bufdo Bdelete" },
		{ cmd.LYRDBufferForceClose, ":Bdelete!" },
		{ cmd.LYRDWindowZoom, ":SimpleZoomToggle" },
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

	-- Disable saving for special filetypes
	for _, value in pairs(L.special_filetypes) do
		if not value.allow_saving then
			commands.implement(value.type_id, {
				{
					cmd.LYRDBufferSave,
					function()
						vim.notify("No saving", vim.log.levels.WARN)
					end,
				},
			})
		end
	end
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
