local setup = require "setup"
local commands = require "layers.commands"

local L = {name = 'Development'}

function L.plugins(s)
    setup.plugin(s, {
        'tpope/vim-commentary',
        'Chiel92/vim-autoformat',
        'norcalli/nvim-colorizer.lua',
        'SirVer/ultisnips',
        'honza/vim-snippets'
    })
end

function L.settings(s)
    require'colorizer'.setup()
    vim.g.UltiSnipsExpandTrigger = "<tab>"
    vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"

    commands.implement(s, '*', {LYRDBufferFormat = ':Autoformat'})
end

function L.keybindings(s) end

function L.complete(s) end

return L
