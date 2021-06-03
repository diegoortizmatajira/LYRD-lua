local setup = require "setup"
local commands = require "layers.commands"

local L = {name = 'Development'}

function L.plugins(s)
    setup.plugin(s, {
        'tpope/vim-commentary',
        'vim-autoformat/vim-autoformat',
        'norcalli/nvim-colorizer.lua',
        'SirVer/ultisnips',
        'honza/vim-snippets',
        'steelsojka/pears.nvim',
    })
end

function L.settings(s)
    require'colorizer'.setup()
    require "pears".setup()
    vim.g.UltiSnipsExpandTrigger = "<tab>"
    vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"

    commands.implement(s, '*', {LYRDBufferFormat = ':Autoformat'})
end

return L
