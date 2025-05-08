local L = {
	name = "General",
	vscode_compatible = true,
}

function L.preparation()
	vim.g.mapleader = ","
	vim.g.maplocalleader = "\\"
	vim.g.big_file = { size = 1024 * 5000, lines = 50000 } -- For files bigger than this, disable 'treesitter' (+5Mb).

	vim.opt.autochdir = false -- Use current file dir as working dir (See project.nvim).
	vim.opt.backspace:append({ "indent", "eol", "start", "nostop" }) -- Don't stop backspace at insert.
	vim.opt.backup = false
	vim.opt.breakindent = true -- Wrap indent to match  line start.
	vim.opt.clipboard = "unnamedplus" -- Connection to the system clipboard.
	vim.opt.cmdheight = 1 -- Hide command line unless needed.
	vim.opt.colorcolumn = "" -- Vertical column for visual hinting (string numeric value), default is "".
	vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Options for insert mode completion.
	vim.opt.copyindent = true -- Copy the previous indentation on autoindenting.
	vim.opt.cursorline = true -- Highlight the text line of the cursor.
	vim.opt.diffopt:append({ "algorithm:histogram", "linematch:60" }) -- Enable linematch diff algorithm
	vim.opt.expandtab = true -- Enable the use of space in tab.
	vim.opt.fileformats = "unix,dos,mac"
	vim.opt.fillchars = { eob = " " } -- Disable `~` on nonexistent lines.
	vim.opt.foldcolumn = "1" -- Show foldcolumn in nvim 0.9+.
	vim.opt.foldenable = true -- Enable fold for nvim-ufo.
	vim.opt.foldlevel = 99 -- set highest foldlevel for nvim-ufo.
	vim.opt.foldlevelstart = 99 -- Start with all code unfolded.
	vim.opt.foldmethod = "syntax"
	vim.opt.guicursor = "n:blinkon200,i-ci-ve:ver25" -- Enable cursor blink.
	vim.opt.hidden = true
	vim.opt.history = 1000 -- Number of commands to remember in a history table (per buffer).
	vim.opt.hlsearch = true
	vim.opt.ignorecase = true -- Case insensitive searching.
	vim.opt.incsearch = true
	vim.opt.infercase = true -- Infer cases in keyword completion.
	vim.opt.laststatus = 3 -- Global statusline.
	vim.opt.linebreak = true -- Wrap lines at 'breakat'.
	vim.opt.modeline = true
	vim.opt.modelines = 10

	local is_android = vim.fn.isdirectory("/data") == 1
	if is_android then
		vim.opt.mouse = "v"
	else
		vim.opt.mouse = "a"
	end -- Enable scroll for android

	vim.opt.mousemodel = "popup"
	vim.opt.mousescroll = "ver:1,hor:0" -- Disables hozirontal scroll in neovim.
	vim.opt.number = true -- Show numberline.
	vim.opt.preserveindent = true -- Preserve indent structure as much as possible.
	vim.opt.pumheight = 10 -- Height of the pop up menu.
	vim.opt.relativenumber = false -- Show relative numberline.
	vim.opt.scrolloff = 3 -- Number of lines to leave before/after the cursor when scrolling. Setting a high value keep the cursor centered.
	vim.opt.selection = "old" -- Don't select the newline symbol when using <End> on visual mode.
	vim.opt.shada = "!,'1000,<50,s10,h" -- Remember the last 1000 opened files
	vim.opt.shell = vim.fn.expand("$SHELL")
	vim.opt.shiftwidth = 4 -- Number of space inserted for indentation.
	vim.opt.shortmess:append({ c = true, s = true, I = true }) -- Disable startup message.
	vim.opt.showmode = false -- Disable showing modes in command line.
	vim.opt.sidescrolloff = 8 -- Same but for side scrolling.
	vim.opt.signcolumn = "yes" -- Always show the sign column.
	vim.opt.smartcase = true -- Case sensitivie searching.
	vim.opt.smartindent = true -- Smarter autoindentation.
	vim.opt.softtabstop = 0
	vim.opt.splitbelow = true -- Splitting a new window below the current one.
	vim.opt.splitright = true -- Splitting a new window at the right of the current one.
	vim.opt.swapfile = false -- Ask what state to recover when opening a file that was not saved.
	vim.opt.tabstop = 4 -- Number of space in a tab.
	vim.opt.termguicolors = true -- Enable 24-bit RGB color in the TUI.
	vim.opt.title = true
	vim.opt.titleold = "Terminal"
	vim.opt.titlestring = "%F"
	vim.opt.undodir = vim.fn.expand("~/.config/nvim/undo/")
	vim.opt.undofile = true -- Enable persistent undo between session and reboots.
	vim.opt.updatetime = 300 -- Length of time to wait before triggering the plugin.
	vim.opt.viewoptions:remove("curdir") -- Disable saving current directory with views.
	vim.opt.virtualedit = "block" -- Allow going past end of line in visual block mode.
	vim.opt.wrap = false -- Disable wrapping of lines longer than the width of window.
	vim.opt.writebackup = false -- Disable making a backup before overwriting a file.

	vim.api.nvim_create_user_command("FixWhitespace", ":%s/\\s\\+$//e", {})
	-- *****************************************************************************
	-- Autocmd Rules
	-- *****************************************************************************
	local completion_preview_close_group = vim.api.nvim_create_augroup("completion_preview_close", {})
	vim.api.nvim_create_autocmd({ "CompleteDone" }, {
		group = completion_preview_close_group,
		pattern = { "*" },
		command = "if !&previewwindow && &completeopt =~ 'preview' | silent! pclose | endif",
	})

	vim.cmd([[ set autoread ]])

	-- Sets the cursor
	vim.cmd([[set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]])
end

return L
