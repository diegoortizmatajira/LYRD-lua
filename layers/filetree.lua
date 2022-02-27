local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"

local L = {name = 'File tree'}

function L.plugins(s)
    setup.plugin(s, {'kyazdani42/nvim-web-devicons', 'kyazdani42/nvim-tree.lua'})
end

function L.settings(s)
    require'nvim-tree'.setup{
        disable_netrw = false,
        auto_close = true,
        update_cwd = true,
        diagonostics = {enable = true},
        view = {width = 60, side = 'right'},
        filters = {
            dotfiles = false,
            custom = {'.git', 'node_modules', '.cache', 'bin', 'obj'}
        },
        git = {
            ignore = 1
        },
        actions = {
            open_file = {
                quit_on_open = true
            }
        }
    }
    vim.g.nvim_tree_icons = {
        default = '',
        symlink = '',
        git = {
            unstaged = "u{f8eb}",
            staged = "u{f8ec}",
            unmerged = "u{f5f7}",
            renamed = "u{f45a}",
            untracked = "u{f893}"
        },
        folder = {default = "", open = "", symlink = ""}
    }

    commands.implement(s, '*', {LYRDViewFileTree = ':NvimTreeFindFileToggle', LYRDViewFileExplorer = ':Ntree'})
end

return L
