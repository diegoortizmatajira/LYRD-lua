local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "File tree" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"nvim-tree/nvim-tree.lua",
			version = "*",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			opts = {
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
				sort = {
					sorter = "name",
					folders_first = true,
					files_first = false,
				},
				view = {
					adaptive_size = false,
					centralize_selection = true,
					width = 60,
					cursorline = true,
					debounce_delay = 15,
					side = "right",
					preserve_window_proportions = false,
					number = false,
					relativenumber = false,
					signcolumn = "yes",
					float = {
						enable = false,
						quit_on_focus_loss = true,
						open_win_config = {
							relative = "editor",
							border = "rounded",
							width = 30,
							height = 30,
							row = 1,
							col = 1,
						},
					},
				},
				renderer = {
					indent_markers = {
						enable = true,
						inline_arrows = true,
						icons = {
							corner = "└",
							edge = "│",
							item = "│",
							bottom = "─",
							none = " ",
						},
					},
					icons = {
						web_devicons = {
							file = {
								enable = true,
								color = true,
							},
							folder = {
								enable = false,
								color = true,
							},
						},
						git_placement = "before",
						modified_placement = "after",
						hidden_placement = "after",
						diagnostics_placement = "signcolumn",
						bookmarks_placement = "signcolumn",
						padding = " ",
						symlink_arrow = " ➛ ",
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
							modified = true,
							hidden = false,
							diagnostics = true,
							bookmarks = true,
						},
						glyphs = {
							default = "",
							symlink = "",
							bookmark = "󰆤",
							modified = "●",
							hidden = "󰜌",
							folder = {
								arrow_closed = "󰅂",
								arrow_open = "󰅀",
								default = "󰉋",
								open = "󰝰",
								empty = "󰉖",
								empty_open = "󰷏",
								symlink = "",
								symlink_open = "",
							},
							git = {
								unstaged = "",
								staged = "✓",
								unmerged = "",
								renamed = "➜",
								untracked = "★",
								deleted = "",
								ignored = "◌",
							},
						},
					},
				},
				update_focused_file = {
					enable = true,
					update_root = true,
				},
				disable_netrw = false,
				update_cwd = true,
				diagnostics = { enable = true, show_on_dirs = true },
				filters = {
					dotfiles = true,
					-- custom = { "^\\.git$", "^node_modules$", "^\\.cache$", "^bin$", "^obj$" },
					custom = { "^\\.git$", "^node_modules$", "^bin$", "^obj$" },
					exclude = { ".gitignore" },
				},
				git = { ignore = true },
				actions = { open_file = { quit_on_open = true } },
			},
		},
		{
			"nvim-tree/nvim-web-devicons",
			opts = {
				-- your personnal icons can go here (to override)
				-- you can specify color or cterm_color instead of specifying both of them
				-- DevIcon will be appended to `name`
				override = {
					default = "",
					symlink = "",
					git = {
						unstaged = "\u{f8eb}",
						staged = "\u{f8ec}",
						unmerged = "\u{f5f7}",
						renamed = "\u{f45a}",
						untracked = "\u{f893}",
					},
					zsh = {
						icon = "",
						color = "#428850",
						cterm_color = "65",
						name = "Zsh",
					},
				},
				-- globally enable different highlight colors per icon (default to true)
				-- if set to false all icons will have the default icon's color
				color_icons = true,
				-- globally enable default icons (default to false)
				-- will get overriden by `get_icons` option
				default = true,
				-- globally enable "strict" selection of icons - icon will be looked up in
				-- different tables, first by filename, and if not found by extension; this
				-- prevents cases when file doesn't have any extension but still gets some icon
				-- because its name happened to match some extension (default to false)
				strict = true,
				-- same as `override` but specifically for overrides by filename
				-- takes effect when `strict` is true
				override_by_filename = {
					[".gitignore"] = {
						icon = "",
						color = "#f1502f",
						name = "Gitignore",
					},
				},
				-- same as `override` but specifically for overrides by extension
				-- takes effect when `strict` is true
				override_by_extension = {
					["log"] = {
						icon = "",
						color = "#81e043",
						name = "Log",
					},
				},
			},
		},
		{
			"rolv-apneseth/tfm.nvim",
			lazy = false,
			opts = {
				-- TFM to use
				-- Possible choices: "ranger" | "nnn" | "lf" | "vifm" | "yazi" (default)
				file_manager = "yazi",
				-- Replace netrw entirely
				-- Default: false
				replace_netrw = true,
				-- Enable creation of commands
				-- Default: false
				-- Commands:
				--   Tfm: selected file(s) will be opened in the current window
				--   TfmSplit: selected file(s) will be opened in a horizontal split
				--   TfmVsplit: selected file(s) will be opened in a vertical split
				--   TfmTabedit: selected file(s) will be opened in a new tab page
				enable_cmds = false,
				-- Custom keybindings only applied within the TFM buffer
				-- Default: {}
				keybindings = {
					-- Override the open mode (i.e. vertical/horizontal split, new tab)
					-- Tip: you can add an extra `<CR>` to the end of these to immediately open the selected file(s) (assuming the TFM uses `enter` to finalise selection)
					["<C-v>"] = "<C-\\><C-O>:lua require('tfm').set_next_open_mode(require('tfm').OPEN_MODE.vsplit)<CR>",
					["<C-x>"] = "<C-\\><C-O>:lua require('tfm').set_next_open_mode(require('tfm').OPEN_MODE.split)<CR>",
					["<C-t>"] = "<C-\\><C-O>:lua require('tfm').set_next_open_mode(require('tfm').OPEN_MODE.tabedit)<CR>",
				},
				-- Customise UI. The below options are the default
				ui = {
					border = "rounded",
					height = 1,
					width = 1,
					x = 0.5,
					y = 0.5,
				},
			},
		},
	})
end

function L.settings(s)
	commands.implement(s, "NvimTree", {
		{ cmd.LYRDBufferSave, [[:echo 'No saving']] },
	})
	commands.implement(s, "*", {
		{ cmd.LYRDViewFileTree, ":NvimTreeFindFileToggle" },
		{ cmd.LYRDViewFileExplorer, require("tfm").open },
	})
end

return L
