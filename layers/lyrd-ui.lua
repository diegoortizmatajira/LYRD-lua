local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")
local utils = require("LYRD.utils")

---@class LYRD.layer.LYRDUI: LYRD.setup.Module
--- @field decoration_togglers table<string, CommandImplementation[]> List of togglers for UI decorations per filetype
local L = {
	name = "LYRD UI",
	decoration_togglers = {},
}

local ext_app_term = nil -- Store the terminal object

local lyrd_ui_group = vim.api.nvim_create_augroup("LYRD-ui", {})

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

local function macro_recording()
	local reg = vim.fn.reg_recording()
	if reg ~= "" then
		return "Recording @" .. reg
	end
	return ""
end

local function current_database()
	return require("db-cli-adapter").get_current_db_connection()
end

--- Registers implementations for toggling UI decorations for a specific filetype.
--- @param filetype string|string[] The filetype for which to register the togglers.
--- @param implementations CommandImplementation[] List of implementations to register.
function L.register_decoration_togglers(filetype, implementations)
	if type(filetype) == "string" then
		filetype = { filetype }
	end
	vim.tbl_map(function(ft)
		if not L.decoration_togglers[ft] then
			L.decoration_togglers[ft] = {}
		end
		for _, impl in ipairs(implementations) do
			table.insert(L.decoration_togglers[ft], impl)
		end
	end, filetype)
end

--- Toggles UI decorations for the current buffer based on its filetype.
--- @param opts? table|nil Optional options to pass to the command implementations.
function L.toggle_decorations(opts)
	local function run_for_filetype(filetype)
		local togglers = L.decoration_togglers[filetype]
		if not togglers then
			return false
		end
		for _, impl in ipairs(togglers) do
			commands.execute_implementation(impl, opts)
		end
		return true
	end
	local ft = vim.bo.filetype
	run_for_filetype(ft)
	run_for_filetype("*") -- Run for global togglers as well
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
				tabline = {
					lualine_a = { "buffers" },
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = { current_database },
					lualine_z = { "tabs" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { macro_recording, "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
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
				--- customizes how the file path is appendned to the item text (aligned with file_formatter function for splitting)
				local show_path = function(path)
					return string.format("|%s%s", vim.fn.fnamemodify(path, ":~:.:h"), utils.path_sep)
				end
				--- custom file formatter to show brackets, icons and paths using different highlight groups
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
							if vim.tbl_contains(exclude_sections, item.section) then
								local parts = vim.split(unit.string, "|")
								local icon_unit = {
									string = (#parts > 1 and parts[2] or "") .. " ",
									type = "item_icon",
									hl = "Function",
									-- Use `_item` instead of `item` because it is better to be 'private'
									_item = unit.item,
								}
								local text_unit = {

									string = #parts == 3 and parts[3] or "",
									type = "item_text",
									hl = "MiniStarterItem",
									-- Use `_item` instead of `item` because it is better to be 'private'
									_item = unit.item,
								}
								table.insert(content[c.line], c.unit, rbracket_unit)
								table.insert(content[c.line], c.unit + 2, lbracket_unit)
								table.insert(content[c.line], c.unit + 3, icon_unit)
								table.insert(content[c.line], c.unit + 4, text_unit)
								unit.string = parts[1] or unit.string
							else
								if cur_section ~= item.section then
									cur_section = item.section
									-- Cycle through lower case letters
									n_section = n_section + 1
									n_item = per_section and 0 or n_item
								end

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
								unit.string = ("%d"):format(n_section * 10 + n_item)
								n_item = n_item + 1
							end
						end

						return content
					end
				end
				-- Overrides to match a better color scheme
				local function set_matching_ministarter_colorscheme()
					-- Highlight groups to match the current colorscheme
					vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { link = "Constant" })
					vim.api.nvim_set_hl(0, "MiniStarterHeader", { link = "Type" })
					vim.api.nvim_set_hl(0, "MiniStarterQuery", { link = "Constant" })
					-- vim.api.nvim_set_hl(0, "MiniStarterCurrent", { link = "MiniStarterItem" })
					-- vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "Title" })
					-- vim.api.nvim_set_hl(0, "MiniStarterInactive", { link = "Comment" })
					-- vim.api.nvim_set_hl(0, "MiniStarterItem", { link = "Normal" })
					-- vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { link = "Delimiter" })
					-- vim.api.nvim_set_hl(0, "MiniStarterSection", { link = "Delimiter" })
				end
				--- Sets up the mini.starter with custom options
				starter.setup({
					--- Include only numbers and specific letters for common actions to allow j/k navigation
					query_updaters = "ewq0123456789",
					evaluate_single = true,
					header = header(),
					items = {
						{
							name = string.format("e|%s|Edit new buffer", icons.file.new),
							action = "enew",
							section = "Common actions",
						},
						{
							name = string.format("w|%s|Select workspace", icons.other.workspace),
							action = "Telescope workspaces",
							section = "Common actions",
						},
						{
							name = string.format("q|%s|Quit Neovim", icons.action.exit),
							action = "qall",
							section = "Common actions",
						},
						starter.sections.recent_files(10, true, show_path),
						starter.sections.recent_files(10, false, show_path),
						-- Use this if you set up 'mini.sessions'
						-- starter.sections.sessions(5, true),
					},
					footer = "LYRD® Neovim by Diego Ortiz. 2023",
					content_hooks = {
						starter.gen_hook.adding_bullet(),
						file_formatter("section", { "Common actions" }),
						starter.gen_hook.padding(3, 2),
						-- starter.gen_hook.aligning("center", "center"),
					},
				})
				set_matching_ministarter_colorscheme()
				--- Ensure colors match on colorscheme change
				vim.api.nvim_create_autocmd(
					"ColorScheme",
					{ group = lyrd_ui_group, callback = set_matching_ministarter_colorscheme, desc = "Ensure colors" }
				)
				-- Map `j` and `k` to navigate items
				vim.api.nvim_create_autocmd("User", {
					group = lyrd_ui_group,
					pattern = "MiniStarterOpened",
					--stylua: ignore
					callback = function()
						vim.api.nvim_buf_del_keymap(0, "n", "<C-p>")
						vim.api.nvim_buf_del_keymap(0, "n", "<C-n>")
						vim.api.nvim_buf_set_keymap( 0, "n", "j", "<Cmd>lua MiniStarter.update_current_item('next')<CR>", { noremap = true, silent = true })
						vim.api.nvim_buf_set_keymap( 0, "n", "k", "<Cmd>lua MiniStarter.update_current_item('prev')<CR>", { noremap = true, silent = true })
					end,
				})
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
			"diegoortizmatajira/workspace-scratch-files.nvim",
			-- dir = "/home/diegoortizmatajira/Development/contrib/workspace-scratch-files.nvim",
			opts = {},
		},
		{
			"MagicDuck/grug-far.nvim",
			-- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
			-- additional lazy config to defer loading is not really needed...
			opts = {},
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
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = lyrd_ui_group,
		pattern = { "*" },
		command = ":syntax sync maxlines=200",
	})

	-- Remember cursor position
	vim.api.nvim_create_autocmd({ "BufReadPost" }, {
		group = lyrd_ui_group,
		pattern = { "*" },
		command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]],
	})

	-- Highlight the yanked text
	vim.api.nvim_create_autocmd({ "TextYankPost" }, {
		group = lyrd_ui_group,
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
		{ cmd.LYRDScratchNew, ":ScratchNew" },
		{ cmd.LYRDScratchOpen, ":ScratchSearch" },
		{ cmd.LYRDScratchDelete, ":ScratchDelete" },
		{ cmd.LYRDScratchSearch, ":ScratchSearch" },
		{ cmd.LYRDViewFocusMode, ":Twilight" },
		{ cmd.LYRDTerminal, ":ToggleTerm" },
		{ cmd.LYRDTerminalList, ":TermSelect" },
		{
			cmd.LYRDReplace,
			function()
				require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
			end,
		},
		{ cmd.LYRDReplaceInFiles, ":GrugFar" },
		{ cmd.LYRDToggleBufferDecorations, L.toggle_decorations },
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
