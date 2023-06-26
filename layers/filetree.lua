local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "File tree" }

function L.plugins(s)
	setup.plugin(s, { "nvim-tree/nvim-web-devicons", "nvim-tree/nvim-tree.lua" })
end

function L.settings(s)
	commands.implement(s, "NvimTree", {
		{ cmd.LYRDBufferSave, [[:echo 'No saving']] },
	})
	require("nvim-tree").setup({
		disable_netrw = false,
		update_cwd = true,
		diagnostics = { enable = true, show_on_dirs = true },
		view = { width = 60, side = "right" },
		filters = {
			dotfiles = true,
			-- custom = { "^\\.git$", "^node_modules$", "^\\.cache$", "^bin$", "^obj$" },
			custom = { "^\\.git$", "^node_modules$", "^bin$", "^obj$" },
			exclude = { ".gitignore" },
		},
		git = { ignore = true },
		actions = { open_file = { quit_on_open = true } },
	})
	require("nvim-web-devicons").setup({
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
	})
	commands.implement(s, "*", {
		{ cmd.LYRDViewFileTree, ":NvimTreeFindFileToggle" },
		{ cmd.LYRDViewFileExplorer, ":Ntree" },
	})
end

return L
