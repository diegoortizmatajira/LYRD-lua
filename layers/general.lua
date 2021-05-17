local setup = require("setup")

local L = {
    name = 'General'
}

function L.plugins(s)
end

function L.settings(s)
    -- Map leader to ,
    vim.g.mapleader = ","

    vim.o.undodir = "~/.config/nvim/undo/"
    vim.o.undofile = true

    vim.o.splitright = true
    vim.o.splitbelow = true

    vim.o.swapfile = false
    vim.o.mouse = "a"

    vim.o.foldenable = false

    -- Encoding
    vim.o.encoding = "utf-8"
    vim.o.fileencoding = "utf-8"
    vim.o.fileencodings = "utf-8"

    -- Fix backspace indent
    vim.o.backspace = "indent,eol,start"

    -- Tabs. May be overridden by autocmd rules
    vim.o.tabstop = 4
    vim.o.softtabstop = 0
    vim.o.shiftwidth = 4
    vim.o.expandtab = true

    -- Enable hidden buffers
    vim.o.hidden = true

    -- Some servers have issues with backup files, see #649
    vim.o.backup = false
    vim.o.writebackup = false

    -- Better display for messages
    vim.o.cmdheight = 1

    -- Smaller updatetime for CursorHold & CursorHoldI
    vim.o.updatetime = 300

    -- always show signcolumns
    vim.o.signcolumn = "yes"

    -- Searching
    vim.o.hlsearch = true
    vim.o.incsearch = true
    vim.o.ignorecase = true
    vim.o.smartcase = true

    vim.o.fileformats = "unix,dos,mac"

    vim.o.shell = "$SHELL"
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.wrap = false

    vim.o.mousemodel = "popup"
    vim.o.t_Co = "256"
    -- vim.o.guioptions = "egmrti"
    vim.o.termguicolors = true

    -- Disable the blinking cursor.
    vim.o.gcr = "a:blinkon0"
    vim.o.scrolloff = 3

    -- Status bar
    vim.o.laststatus = 2

    -- Use modeline overrides
    vim.o.modeline = true
    vim.o.modelines = 10

    vim.o.title = true
    vim.o.titleold = "Terminal"
    vim.o.titlestring = "%F"
end

function L.keybindings(s)
end

function L.complete(s)
end

return L
