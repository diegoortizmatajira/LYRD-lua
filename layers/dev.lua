local setup = require "setup"

local L = {
    name = 'Development'
}

function L.plugins(s)
    setup.plugin(s,
        {
            'tpope/vim-commentary',
            'Chiel92/vim-autoformat',
            'norcalli/nvim-colorizer.lua',
        })
end

function L.settings(s)
    require'colorizer'.setup()
end

function L.keybindings(s)
end

function L.complete(s)
end

return L
