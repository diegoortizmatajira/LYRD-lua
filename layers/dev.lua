local setup = require "LYRD.setup"
local commands = require "LYRD.layers.commands"

local L = {name = 'Development'}

function L.plugins(s)
    setup.plugin(s, {
        'tpope/vim-commentary',
        'vim-autoformat/vim-autoformat',
        'norcalli/nvim-colorizer.lua',
        'steelsojka/pears.nvim',
    })
end

function L.settings(s)
    require'colorizer'.setup()
    require 'pears'.setup()
    commands.implement(s, '*', {LYRDBufferFormat = ':Autoformat'})
end

return L
