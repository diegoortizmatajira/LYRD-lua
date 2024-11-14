local setup = require("LYRD.setup")

local L = {
	name = "Icons",
	no_icon = " ",
	other = {
		ia = "󱜙",
		home = "󰋜",
		wrench = "",
		project = "",
		workspace = "",
		report = "󰃯",
	},
	apps = {
		git = "󰊢",
		browser = "󰖟",
		terminal = "",
		file_explorer = "󱏓",
	},
	diagnostic = {
		search = "󰺅",
		next = "󰮱",
		prev = "󰮳",
		error = "",
		warning = "",
		hint = "",
		info = "",
	},
	search = {
		default = "",
		lines = "󱎸",
		tags = "󱤇",
		buffers = "󱈇",
		history = "󰋚",
		commands = "",
		files = "󰱼",
		keys = "",
	},
	action = {
		clean = "󰃢",
		install = "󰃘",
		update = "󱪍",
		code_action = "",
		close = "",
		format = "󰉢",
		close_many = "",
		cut = "",
		copy = "",
		paste = "",
		save = "",
		save_all = "",
		kill = "󰚌",
		kill_target = "󱓇",
		break_line = "󰌑",
		toggle_on = "󰨚",
		toggle_off = "󰨙",
		split_h = "",
		split_v = "",
		wrap = "",
		repeat_once = "󰑘",
	},
	arrow = {
		up_left = "󱞧",
		up_right = "󱞫",
		right_up = "󱞿",
		left_up = "󱞽",
		right_down = "󱞣",
		left_down = "󱞡",
		down_left = "󱞥",
		down_right = "󱞩",
	},
	debug = {
		breakpoint = "",
		pause = "",
		play = "",
		step_into = "",
		step_over = "",
		step_out = "",
		step_back = "",
		run_last = "",
		terminate = "",
	},
	code = {
		-- Actions
		build = "󰙵",
		outline = "󱏒",
		fix = "󰁨",
		generate = "󱃖",
		check = "󰚔",
		refactor = "",
		run = "",
		navigate = "",
		hint = "",
		rename = "",
		test = "󰙨",
		-- Code elements
		symbol = "",
		class = " ",
		color = " ",
		constant = "󰏿 ",
		constructor = " ",
		enum = " ",
		enummember = " ",
		event = " ",
		field = " ",
		file = " ",
		folder = " ",
		func = "󰊕 ",
		interface = " ",
		keyword = " ",
		method = " ",
		module = " ",
		operator = " ",
		property = " ",
		reference = " ",
		snippet = " ",
		struct = " ",
		text = " ",
		typeparameter = " ",
		unit = " ",
		value = " ",
		variable = " ",
	},
	git = {
		-- Actions
		branch = "",
		commit = "",
		merge = "",
		pull_request = "",
		commit_start = "󰜝",
		commit_end = "󰜙",
		pull = "",
		push = "",
		clone = "",
		stage = "󰱒",
		stage_all = "󰱑",
		unstage = "",
		unstage_all = "󰄷",
		status = "",
		log = "",
		diff = "",
		blame = "",
		init = "",
		-- Status
		unstaged = "",
		staged = "✓",
		unmerged = "",
		renamed = "➜",
		untracked = "★",
		deleted = "",
		ignored = "◌",
	},
	git_gutter = {
		add = "┃",
		change = "┃",
		delete = "_",
		topdelete = "‾",
		changedelete = "~",
		untracked = "┆",
	},
	tree_lines = {
		corner = "└",
		edge = "│",
		item = "│",
		bottom = "─",
	},
	folder = {
		new = "",
		default = "󰉋",
		open = "󰝰",
		empty = "󰉖",
		empty_open = "󰷏",
		symlink = "",
		symlink_open = "",
	},
	file = {
		new = "",
		swap = "󰾵",
		default = "",
		symlink = "",
		scratch = "󱞁",
	},
	chevron = {
		right = "󰅂",
		left = "",
		up = "",
		down = "󰅀",
		double_right = "󰄾",
		double_left = "󰄽",
		double_up = "󰄿",
		double_down = "󰄼",
	},
	triangle = {
		right = "▶",
		left = "◀",
		up = "▲",
		down = "▼",
	},
	status = {
		bookmarked = "󰆤",
		modified = "●",
		hidden = "󰜌",
		busy = "",
		checked = "󰄴",
		unchecked = "󰄰",
		unknown = "",
	},
	test = {
		passed = "",
		skipped = "",
		failed = "",
		success = "",
		reload = "",
	},
	dotnet = {
		sln = "󰘐",
		project = "󰘐",
		package = "",
	},
}

function L.plugins(s)
	setup.plugin(s, {
		{
			"nvim-tree/nvim-web-devicons",
			opts = {
				-- your personnal icons can go here (to override)
				-- you can specify color or cterm_color instead of specifying both of them
				-- DevIcon will be appended to `name`
				override = {
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
	})
end

function L.icon(icon_text, highlight, color)
	return {
		icon = icon_text,
		hl = highlight or "WhichKeyIcon",
		color = color or "cyan",
	}
end

return L
