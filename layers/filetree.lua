local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

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
				sync_root_with_cwd = false,
				respect_buf_cwd = false,
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
							corner = icons.tree_lines.corner,
							edge = icons.tree_lines.edge,
							item = icons.tree_lines.item,
							bottom = icons.tree_lines.bottom,
							none = icons.no_icon,
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
							default = icons.file.default,
							symlink = icons.file.symlink,
							bookmark = icons.status.bookmarked,
							modified = icons.status.modified,
							hidden = icons.status.hidden,
							folder = {
								arrow_closed = icons.chevron.right,
								arrow_open = icons.chevron.down,
								default = icons.folder.default,
								open = icons.folder.open,
								empty = icons.folder.empty,
								empty_open = icons.folder.empty_open,
								symlink = icons.folder.symlink,
								symlink_open = icons.folder.symlink_open,
							},
							git = {
								unstaged = icons.git.unstaged,
								staged = icons.git.staged,
								unmerged = icons.git.unmerged,
								renamed = icons.git.renamed,
								untracked = icons.git.untracked,
								deleted = icons.git.deleted,
								ignored = icons.git.ignored,
							},
						},
					},
				},
				disable_netrw = false,
				hijack_directories = {
					enable = true,
					auto_open = true,
				},
				update_focused_file = {
					enable = false,
					update_root = {
						enable = false,
						ignore_list = {},
					},
					exclude = false,
				},
				diagnostics = {
					icons = {
						hint = icons.diagnostic.hint,
						info = icons.diagnostic.info,
						warning = icons.diagnostic.warning,
						error = icons.diagnostic.error,
					},
				},
				filters = {
					enable = true,
					git_ignored = true,
					dotfiles = false,
					git_clean = false,
					no_buffer = false,
					no_bookmark = false,
					custom = { "^\\.git$", "^node_modules$", "^bin$", "^obj$" },
					exclude = { ".gitignore" },
				},
				actions = {
					open_file = {
						quit_on_open = true,
					},
					change_dir = {
						enable = true,
						global = false,
						restrict_above_cwd = false,
					},
				},
				notify = {
					threshold = vim.log.levels.WARN,
					absolute_path = true,
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
