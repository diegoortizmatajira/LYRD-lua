local setup = require "LYRD.setup"
local mappings = require "LYRD.layers.mappings"
local commands = require "LYRD.layers.commands"
local c = commands.command_shortcut

local L = {name = 'Motions'}

function L.plugins(s) setup.plugin(s, {
    'phaazon/hop.nvim'
}) end

function L.settings(s)
    require('hop').setup {
        keys = "fjdksla;gh"
    }
end

function L.keybindings(s)
    mappings.leader(s, {
        {'', {'l'}, c('HopLine'), 'Hop to line'},
        {'', {'w'}, c('HopWord'), 'Hop to word'},
        {'', {','}, c('HopPattern'), 'Hop to pattern'},
    })
    mappings.keys(s, {
        {'', 's', '<cmd>HopChar1<CR>'},
        {'', 'S', '<cmd>HopChar2<CR>'}
    })
end

return L
