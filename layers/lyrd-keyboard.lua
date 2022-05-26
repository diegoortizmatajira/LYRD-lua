local mappings = require"LYRD.layers.mappings"
local commands = require"LYRD.layers.commands"
local c = commands.command_shortcut

local L = {name = 'LYRD Keyboard'}

function L.keybindings(s)
  mappings.keys(s, {
    {'n', '<C-j>', '<C-w>j'},
    {'n', '<C-k>', '<C-w>k'},
    {'n', '<C-h>', '<C-w>h'},
    {'n', '<C-l>', '<C-w>l'},
    {'n', 's', '<nop>'},
    {'n', '<F2>', c('LYRDViewFileTree')},
    {'n', '<F5>', c('LYRDDebugContinue')},
    {'n', '<F9>', c('LYRDDebugBreakpoint')},
    {'n', '<F10>', c('LYRDDebugStepOver')},
    {'n', '<F11>', c('LYRDDebugStepInto')},
    {'n', '<F2>', c('LYRDViewFileTree')},
    {'n', '<S-F2>', c('LYRDViewFileExplorer')},
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
    {'n', [[gpi"]], [[vi""0p]]},
    {'n', [[gpi']], [[vi'"0p]]},
    {'n', '<A-PageUp>', c('LYRDLSPGotoPrevDiagnostic')},
    {'n', '<A-PageDown>', c('LYRDLSPGotoNextDiagnostic')},
    {'n', '<A-Enter>', c('LYRDLSPFindCodeActions')},
    {'n', '<C-r><C-r>', c('LYRDLSPRename')},
    {'n', '<C-r><C-f>', c('LYRDCodeRefactor')},
    {'v', '<C-r><C-f>', c('LYRDCodeRefactor')}
  })
  mappings.leader(s, {
    {'n', {'<Space>'}, c('noh'), 'Clear search highlights'},
    {'n', {'.'}, c('LYRDViewHomePage'), 'Home page'},
    {'n', {'b'}, c('LYRDBreakLine'), 'Break current line'},
    -- {'n', {'b'}, "<ESC>:s/[,(]/\0/ge<CR><BAR>:'[,']normal ==<CR><BAR>:noh<CR>", 'Break current line'},
    {'n', {'s'}, c('LYRDBufferSave'), 'Save buffer content'},
    {'n', {'c'}, c('LYRDBufferClose'), 'Close buffer'},
    {'n', {'C'}, c('LYRDBufferCloseAll'), 'Close all buffers'},
    {'n', {'h'}, c('LYRDBufferSplitH'), 'Horizonal split'},
    {'n', {'v'}, c('LYRDBufferSplitV'), 'Vertical split'},
    {'n', {'z'}, c('LYRDBufferPrev'), 'Previous buffer'},
    {'n', {'x'}, c('LYRDBufferNext'), 'Next buffer'},
    {'n', {'a'}, c('LYRDLSPFindCodeActions'), 'Actions'},
    {'n', {'A'}, c('LYRDLSPFindRangeCodeActions'), 'Range Actions'},
    {'n', {'f'}, c('LYRDBufferFormat'), 'Format document'},
    {'n', {'d'}, c('LYRDDebugToggleUI'), 'Toggle Debug UI'},
    {'n', {'r', 'n'}, c('LYRDLSPRename'), 'Rename Symbol'},
    {'n', {'r', 'f'}, c('LYRDCodeRefactor'), 'Refactor'},
    {'v', {'r', 'f'}, c('LYRDCodeRefactor'), 'Refactor'}

  })
end

return L
