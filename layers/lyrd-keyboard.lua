local mappings = require "LYRD.layers.mappings"
local commands = require "LYRD.layers.commands"
local c = commands.command_shortcut

local L = {name = 'LYRD Keyboard'}

function L.keybindings(s)
    mappings.keys(s, {
        {'n', '<F2>', c('LYRDViewFileTree')},
        {'n', '<C-s>', c('LYRDBufferSave')},
        {'i', '<C-s>', '<Esc>' .. c('LYRDBufferSave')},
        {'n', '<C-p>', c('LYRDSearchFiles')},
        {'n', '<A-Left>', c('LYRDBufferPrev')},
        {'n', '<A-Right>', c('LYRDBufferNext')},
        {'n', '<C-F4>', c('LYRDBufferClose')},
        {'n', 'K', c('LYRDLSPHoverInfo')},
        {'n', '<C-k>', c('LYRDLSPSignatureHelp')},
        {'n', 'gd', c('LYRDLSPFindDefinitions')},
        {'n', 'gD', c('LYRDLSPFindDeclaration')},
        {'n', 'gt', c('LYRDLSPFindTypeDefinition')},
        {'n', 'gi', c('LYRDLSPFindImplementations')},
        {'n', 'gr', c('LYRDLSPFindReferences')},
        {'n', 'ga', c('LYRDLSPFindCodeActions')},
        {'n', 'gA', c('LYRDLSPFindRangeCodeActions')},
        {'n', '<A-PageUp>', c('LYRDLSPGotoPrevDiagnostic')},
        {'n', '<A-PageDown>', c('LYRDLSPGotoNextDiagnostic')},
        {'n', '<A-Enter>', c('LYRDLSPFindCodeActions')}
    })
    mappings.leader(s, {
        {'n', {'<Space>'}, c('noh'), 'Clear search highlights'},
        {'n', {'.'}, c('LYRDViewHomePage'), 'Home page'},
        {'n', {'s'}, c('LYRDBufferSave'), 'Save buffer content'},
        {'n', {'c'}, c('LYRDBufferClose'), 'Close buffer'},
        {'n', {'h'}, c('LYRDBufferSplitH'), 'Horizonal split'},
        {'n', {'v'}, c('LYRDBufferSplitV'), 'Vertical split'},
        {'n', {'a'}, c('LYRDLSPFindCodeActions'), 'Actions'},
        {'n', {'A'}, c('LYRDLSPFindRangeCodeActions'), 'Range Actions'}
    })
end

return L
