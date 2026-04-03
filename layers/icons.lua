local setup = require("LYRD.setup")

---@class LYRD.layer.Icons: LYRD.setup.Module
local L = {
	name = "Icons",
	vscode_compatible = true,
	unskippable = true,
	no_icon = " ",
	unicode = {
		lightbulb = "💡",
	},
	ai = {
		assistant = "󱜙 ",
		cli = "󰶭 ",
		prompt = "󰍩 ",
		edit = "󱆿 ",
		select = " ",
		document = "󱋄 ",
	},
	cloud = {
		cloud = "󰅟 ",
		docker = "󰡨 ",
		container = " ",
		service = "󰲋 ",
	},
	other = {
		bookmark = "󰃃",
		briefcase = " ",
		code = " ",
		command = " ",
		database = "",
		docker = "󰡨 ",
		expand = "󰁌 ",
		filter = " ",
		help = "󰘥 ",
		home = "󰋜 ",
		ia = "󱜙 ",
		keyboard = " ",
		kubernetes = "󱃾 ",
		lightbulb = "󰌵",
		palette = " ",
		plug = " ",
		project = " ",
		report = "󰃯 ",
		tools = " ",
		workspace = " ",
		wrench = " ",
		zoom = " ",
		secret = " ",
		environment = " ",
		layers = " ",
		focus = "󰋱 ",
		highlighter = "󰸱 ",
		filetree = "󰙅 ",
		check = "✓",
		task = "󰄴 ",
		launch = " ",
		eye = " ",
		macro = "󱃸 ",
	},
	images = {
		default = " ",
		add = "󱤾 ",
		search = "󰥸 ",
	},
	styles = {
		h1 = "󰉫 ",
		h2 = "󰉬 ",
		h3 = "󰉭 ",
		h4 = "󰉮 ",
		h5 = "󰉯 ",
		h6 = "󰉰 ",
		italic = "󰉷",
		bold = "󰉤",
		underline = "󰊇",
	},
	apps = {
		git = "󰊢 ",
		browser = "󰖟 ",
		terminal = " ",
		file_explorer = "󱏓 ",
	},
	diagnostic = {
		search = "󰺅 ",
		next = "󰮱 ",
		prev = "󰮳 ",
		error = " ",
		warning = " ",
		hint = " ",
		info = " ",
	},
	search = {
		default = " ",
		lines = "󱎸 ",
		tags = "󱤇 ",
		buffers = "󱈇 ",
		layers = "󱈆 ",
		history = "󰋚 ",
		commands = " ",
		files = "󰱼 ",
		keys = " ",
	},
	action = {
		compare = " ",
		exit = "󰩈 ",
		clean = "󰃢 ",
		install = "󰃘 ",
		update = "󱪍 ",
		code_action = " ",
		close = " ",
		format = "󰉢 ",
		close_many = " ",
		cut = " ",
		copy = " ",
		paste = " ",
		save = " ",
		save_all = " ",
		kill = "󰚌 ",
		kill_target = "󱓇 ",
		move = "󰆾 ",
		break_line = "󰌑 ",
		toggle_on = "󰨚 ",
		toggle_off = "󰨙 ",
		view = " ",
		split_h = " ",
		split_v = " ",
		wrap = " ",
		repeat_once = "󰑘 ",
		replace_text = " ",
		replace_in_files = "󰬳 ",
		run_task = "󱖑 ",
		delete = "󰗨 ",
	},
	arrow = {
		swap = " ",
		expand = "󰘖 ",
		collapse = "󰘕 ",
		left = " ",
		right = " ",
		down = " ",
		up = " ",
		up_left = "󱞧 ",
		up_right = "󱞫 ",
		right_up = "󱞿 ",
		left_up = "󱞽 ",
		right_down = "󱞣 ",
		left_down = "󱞡 ",
		down_left = "󱞥 ",
		down_right = "󱞩 ",
		collapse_left = "󰞓 ",
		collapse_right = "󰞔 ",
		collapse_up = "󰞕 ",
		collapse_down = "󰞒 ",
		expand_left = "󰞗 ",
		expand_right = "󰞘 ",
		expand_up = "󰞙 ",
		expand_down = "󰞖 ",
	},
	debug = {
		breakpoint = " ",
		pause = " ",
		play = " ",
		step_into = " ",
		step_over = " ",
		step_out = " ",
		step_back = " ",
		run_last = " ",
		terminate = " ",
		disconnect = " ",
		current_line = " ",
	},
	code = {
		-- Actions
		build = "󰙵 ",
		outline = " ",
		parser = " ",
		fix = "󰁨 ",
		generate = "󱃖 ",
		check = "󰚔 ",
		refactor = " ",
		run = " ",
		navigate = " ",
		hint = " ",
		rename = " ",
		test = "󰙨 ",
		make = "󱜧 ",
		document = "󱪝 ",
		restart = "󰜉",
		-- Code elements
		package = " ",
		symbol = " ",
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
	http = {
		default = "󰖟 ",
		send = "󱅡 ",
		environment = "󰟭 ",
	},
	git = {
		default = " ",
		-- Actions
		branch = " ",
		commit = " ",
		merge = " ",
		pull_request = " ",
		commit_start = "󰜝 ",
		commit_end = "󰜙 ",
		pull = " ",
		push = " ",
		clone = " ",
		stage = "󰱒 ",
		stage_all = "󰱑 ",
		unstage = " ",
		unstage_all = "󰄷 ",
		status = " ",
		log = " ",
		diff = " ",
		blame = " ",
		init = " ",
		worktree = " ",
		conflict = " ",
		-- Status
		unstaged = " ",
		staged = "✓ ",
		unmerged = " ",
		renamed = "➜ ",
		untracked = "★ ",
		deleted = " ",
		ignored = "◌ ",
		-- Github
		github = " ",
		issue = {
			list = " ",
			draft = " ",
			open = " ",
			closed = " ",
			reopened = " ",
			create_branch = "󱓊 ",
			develop_branch = "󱓏 ",
		},
		pr = {
			list = " ",
			pull_request = " ",
			draft = " ",
			open = " ",
			closed = " ",
		},
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
		thin_left = "▏",
	},
	indicators = {
		thin = "│",
		thick = "┃",
	},
	folder = {
		new = " ",
		default = "󰉋 ",
		open = "󰝰 ",
		empty = "󰉖 ",
		empty_open = "󰷏 ",
		symlink = " ",
		symlink_open = " ",
	},
	file = {
		new = " ",
		swap = "󰾵 ",
		default = " ",
		notebook = " ",
		symlink = " ",
		scratch = "󱞁 ",
		lua = " ",
	},
	chevron = {
		right = " ",
		left = " ",
		up = " ",
		down = " ",
		double_right = "󰄾 ",
		double_left = "󰄽 ",
		double_up = "󰄿 ",
		double_down = "󰄼 ",
	},
	triangle = {
		right = "▶ ",
		left = "◀ ",
		up = "▲ ",
		down = "▼ ",
	},
	status = {
		bookmarked = "󰆤 ",
		modified = "● ",
		hidden = "󰜌 ",
		busy = " ",
		checked = "󰄴 ",
		unchecked = "󰄰 ",
		unknown = " ",
	},
	test = {
		passed = " ",
		skipped = " ",
		failed = " ",
		success = " ",
		reload = " ",
	},
	dotnet = {
		sln = "󰘐 ",
		project = "󰘐 ",
		package = " ",
	},
	ui = {
		checkbox_checked = "󰄵 ",
		checkbox_unchecked = "󰄱 ",
	},
}

function L.plugins()
	setup.plugin({
		{
			"nvim-tree/nvim-web-devicons",
			init = function()
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
				vim.g.WebDevIconsNerdTreeAfterGlyphPadding = " "
				vim.g.WebDevIconsNerdTreeGitPluginForceVAlign = 1
				vim.g.webdevicons_enable_denite = 1
				vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
				vim.g.DevIconsEnableFoldersOpenClose = 1
				vim.g.DevIconsEnableFolderPatternMatching = 1
				vim.g.DevIconsEnableFolderExtensionPatternMatching = 1
				vim.g.WebDevIconsUnicodeDecorateFolderNodesExactMatches = 1
			end,
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
					["java"] = {
						icon = "",
						color = "#CC3E44",
						name = "Java",
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

function L.get_filetype_icon(ft)
	local devicons = require("nvim-web-devicons")
	local icon, icon_highlight = devicons.get_icon_by_filetype(ft)
	if not icon then
		icon, icon_highlight = devicons.get_icon_by_filetype("default")
	end
	return { icon = icon, hl = icon_highlight }
end

function L.filetype_icon()
	return L.get_filetype_icon(vim.bo.filetype)
end

--- @param fn string file name or path
--- @return string
local function get_extension(fn)
	local basename = vim.fs.basename(fn)
	local match = basename:match("^.+(%..+)$")
	local ext = ""
	if match ~= nil then
		ext = match:sub(2)
	end
	return ext
end

function L.get_file_icon(filename)
	local ext = get_extension(filename)
	local devicons = require("nvim-web-devicons")
	local icon, hl = devicons.get_icon(filename, ext, { default = true })
	return { icon = icon, hl = hl }
end

return L
