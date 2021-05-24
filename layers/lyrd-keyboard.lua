local mappings = require "layers.mappings"
local commands = require "layers.commands"
local c = commands.command_shortcut

local L = {name = 'LYRD Keyboard'}

function L.keybindings(s)
    mappings.keys(s, {
        {'n', '<F2>', c('LYRDViewFileTree')},
        {'n', '<C-s>', c('LYRDBufferSave')},
        {'i', '<C-s>', '<Esc>' .. c('LYRDBufferSave')},
        {'n', '<C-p>', c('LYRDSearchFiles')},
        {'n', '<A-Left>', c('LYRDBufferNext')},
        {'n', '<A-Right>', c('LYRDBufferPrev')},
        {'n', '<C-F4>', c('LYRDBufferClose')}
    })
    mappings.leader(s, {
        {'n', {'<Space>'}, c('noh'), 'Clear search highlights'},
        {'n', {'s'}, c('LYRDBufferSave'), 'Save buffer content'},
        {'n', {'z'}, c('LYRDBufferPrev'), 'Previous buffer'},
        {'n', {'x'}, c('LYRDBufferNext'), 'Next buffer'},
        {'n', {'c'}, c('LYRDBufferClose'), 'Close buffer'},
        {'n', {'q'}, c('LYRDWindowClose'), 'Close window'},
        {'n', {'h'}, c('LYRDBufferSplitH'), 'Horizonal split'},
        {'n', {'v'}, c('LYRDBufferSplitV'), 'Vertical split'}
    })
end

return L
