local setup = require "LYRD.setup"
local commands = require "LYRD.layers.commands"

local L = {name = 'File tree'}

function L.plugins(s) setup.plugin(s, {'kyazdani42/nvim-web-devicons', 'kyazdani42/nvim-tree.lua'}) end

function L.settings(s)
    vim.g.nvim_tree_side = 'right'
    vim.g.nvim_tree_width = 60
    vim.g.nvim_tree_auto_close = 1
    vim.g.nvim_tree_quit_on_open = 1
    vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache', 'bin', 'obj'}
    vim.g.nvim_tree_icons = {
        default = '',
        symlink = '',
        git = {unstaged = "✗", staged = "✓", unmerged = "", renamed = "➜", untracked = "★"},
        folder = {default = "", open = "", symlink = ""}
    }

    commands.implement(s, '*', {LYRDViewFileTree = ':NvimTreeToggle', LYRDViewFileExplorer = ':NvimTreeToggle'})
end

return L