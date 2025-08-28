local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")
local utils = require("LYRD.utils")

local L = {
	name = "LYRD UI",
}

local ext_app_term = nil -- Store the terminal object

local function combine_ascii_art(base, new, from_line)
	for i = 1, #new, 1 do
		base[from_line + i] = base[from_line + i] .. new[i]
	end
	return table.concat(base, "\n")
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
		[[⣾⡇⠈⠛⠛⠿⣿⣿⣦⠁⠘⢷⣶⣶⡶⠟⢋⣠⣾⡿⠃⠀⠀⠀⠰⠛⠉⠉⠀    LYRD® Neovim by Diego Ortiz. 2023]],
	}
	local title = {
		[[    __      __       .__                                  __                   ]],
		[[   /  \    /  \ ____ |  |   ____  ____   _____   ____   _/  |_  ____           ]],
		[[   \   \/\/   // __ \|  | _/ ___\/  _ \ /     \_/ __ \  \   __\/  _ \          ]],
		[[    \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/   |  | (  <_> )         ]],
		[[     \__/\  /  \___  >____/\___  >____/|__|_|  /\___  >  |__|  \____/          ]],
		[[          \/       \/          \/            \/     \/                         ]],
		[[    ___       ___  ___  _______   ________       _____  ___  ___      ___  __     ___      ___ ]],
		[[   |"  |     |"  \/"  |/"      \ |"      "\     (\"   \|"  \|"  \    /"  ||" \   |"  \    /"  |]],
		[[   ||  |      \   \  /|:        |(.  ___  :)    |.\\   \    |\   \  //  / ||  |   \   \  //   |]],
		[[   |:  |       \\  \/ |_____/   )|: \   ) ||    |: \.   \\  | \\  \/. ./  |:  |   /\\  \/.    |]],
		[[    \  |___    /   /   //      / (| (___\ ||    |.  \    \. |  \.    //   |.  |  |: \.        |]],
		[[   ( \_|:  \  /   /   |:  __   \ |:       :)    |    \    \ |   \\   /    /\  |\ |.  \    /:  |]],
		[[    \_______)|___/    |__|  \___)(________/      \___|\____\)    \__/    (__\_|_)|___|\__/|___|]],
	}
	return combine_ascii_art(image, title, 1)
end

function L.notify(message, level, options)
	local notify = require("notify")
	notify(message, level, options)
end

local file_formatter = function(grouping, exclude_sections)
	grouping = grouping or "all"
	exclude_sections = exclude_sections or {}
	local per_section = grouping == "section"

	return function(content, _)
		local cur_section, n_section, n_item = 0, -1, 0
		local coords = MiniStarter.content_coords(content, "item")

		for _, c in ipairs(coords) do
			local unit = content[c.line][c.unit]
			local item = unit.item

			if not vim.tbl_contains(exclude_sections, item.section) then
				if cur_section ~= item.section then
					cur_section = item.section
					-- Cycle through lower case letters
					n_section = n_section + 1
					n_item = per_section and 0 or n_item
				end

				local section_index = per_section and string.format("%d", n_section) or ""
				local rbracket_unit = {

					string = "[",
					type = "item_bracket",
					hl = "@tag",
					-- Use `_item` instead of `item` because it is better to be 'private'
					_item = unit.item,
				}
				local lbracket_unit = {

					string = "] ",
					type = "item_bracket",
					hl = "@tag",
					-- Use `_item` instead of `item` because it is better to be 'private'
					_item = unit.item,
				}
				local parts = vim.split(unit.string, "|")
				local icon = icons.get_file_icon(parts[1] or unit.string)
				local icon_unit = {
					string = icon.icon .. "  ",
					type = "item_icon",
					hl = icon.hl,
					-- Use `_item` instead of `item` because it is better to be 'private'
					_item = unit.item,
				}
				local path_unit = {

					string = #parts == 2 and parts[2] or "",
					type = "item_text",
					hl = "@comment",
					-- Use `_item` instead of `item` because it is better to be 'private'
					_item = unit.item,
				}
				local filename_unit = {

					string = parts[1] or unit.string,
					type = "item_text",
					hl = "MiniStarterItem",
					-- Use `_item` instead of `item` because it is better to be 'private'
					_item = unit.item,
				}
				table.insert(content[c.line], c.unit, rbracket_unit)
				table.insert(content[c.line], c.unit + 2, lbracket_unit)
				table.insert(content[c.line], c.unit + 3, icon_unit)
				table.insert(content[c.line], c.unit + 4, path_unit)
				table.insert(content[c.line], c.unit + 5, filename_unit)
				unit.string = ("%s%s"):format(section_index, n_item)
				n_item = n_item + 1
			end
		end

		return content
	end
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
						lua = { icon = icons.file.lua },
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
				"muniftanjim/nui.nvim",
				"nvim-tree/nvim-web-devicons",
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
			"echasnovski/mini.starter",
			version = "*",
			config = function()
				local starter = require("mini.starter")
				local show_path = function(path)
					return string.format("|%s%s", vim.fn.fnamemodify(path, ":~:.:h"), utils.path_sep)
				end
				starter.setup({
					--- Include only numbers and specific letters for common actions to allow j/k navigation
					query_updaters = "ewq0123456789",
					evaluate_single = true,
					header = header(),
					items = {
						{ name = "e. Edit new buffer", action = "enew", section = "Common actions" },
						{
							name = "w. Select workspace",
							action = "Telescope workspaces",
							section = "Common actions",
						},
						{ name = "q. Quit Neovim", action = "qall", section = "Common actions" },
						starter.sections.recent_files(10, true, show_path),
						starter.sections.recent_files(10, false, show_path),
						-- Use this if you set up 'mini.sessions'
						-- starter.sections.sessions(5, true),
					},
					content_hooks = {
						starter.gen_hook.adding_bullet(),
						file_formatter("section", { "Common actions" }),
						starter.gen_hook.padding(3, 2),
						starter.gen_hook.aligning("center", "center"),
					},
				})
				-- Map `j` and `k` to navigate items
				local group = vim.api.nvim_create_augroup("MiniStarterJK", {})
				vim.api.nvim_create_autocmd("User", {
					group = group,
					pattern = "MiniStarterOpened",
					callback = function()
						vim.api.nvim_buf_set_keymap(
							0,
							"n",
							"j",
							"<Cmd>lua MiniStarter.update_current_item('next')<CR>",
							{ noremap = true, silent = true }
						)
						vim.api.nvim_buf_set_keymap(
							0,
							"n",
							"k",
							"<Cmd>lua MiniStarter.update_current_item('prev')<CR>",
							{ noremap = true, silent = true }
						)
					end,
				})
				-- Highlight groups to match the current colorscheme
				vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { link = "@constant", default = true })
				vim.api.nvim_set_hl(0, "MiniStarterHeader", { link = "@type", default = true })
				vim.api.nvim_set_hl(0, "MiniStarterQuery", { link = "@constant", default = true })
				-- vim.api.nvim_set_hl(0, "MiniStarterCurrent", { link = "MiniStarterItem" })
				-- vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "Title" })
				-- vim.api.nvim_set_hl(0, "MiniStarterInactive", { link = "Comment" })
				-- vim.api.nvim_set_hl(0, "MiniStarterItem", { link = "Normal" })
				-- vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { link = "Delimiter" })
				-- vim.api.nvim_set_hl(0, "MiniStarterSection", { link = "Delimiter" })
			end,
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
		{
			cmd.LYRDViewHomePage,
			function()
				require("mini.starter").open()
			end,
		},
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
