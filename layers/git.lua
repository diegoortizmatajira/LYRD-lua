local setup = require "setup"

local L = {name = 'Git'}

function L.plugins(s)
    setup.plugin(s, {
        'tpope/vim-fugitive',
        'airblade/vim-gitgutter',
        'tpope/vim-dispatch'
    })
end

function L.settings(s) vim.g.gitgutter_map_keys = 0 end

function L.keybindings(s) end

function L.complete(s) end

return L
