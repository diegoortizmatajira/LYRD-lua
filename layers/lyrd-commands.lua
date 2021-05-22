local setup = require "setup"
local commands = require "layers.commands"
local mappings = require "layers.mappings"

local L = {
    name = 'LYRD Commands'
}

function L.settings(s)
    commands.register(s, {
        LYRDBufferNew = ':enew',
        LYRDBufferSave = ':w',
        LYRDBufferSaveAll = ':wall',
        LYRDBufferClose = ':bd',
        LYRDBufferForceClose = ':bd!',
        LYRDBufferCloseAll = ':bufdo bd',
        LYRDBufferForceCloseAll = ':bufdo bd!',
        LYRDBufferFormat = '',
        LYRDBufferJumpToLast = ':b#',
        LYRDBufferNext = ':bn',
        LYRDBufferPrev = ':bp',
        LYRDBufferSplitV = ':<C-u>vsplit',
        LYRDBufferSplitH = ':<C-u>split',
        LYRDBufferSetReadOnly = ':setl readonly!',
        LYRDBufferCopy = ':normal! ggVG"+y``',
        LYRDBufferPaste = ':normal! ggdG"+P',
        LYRDBufferToggleWrap = ':setlocal wrap!',
        LYRDWindowClose = ':q',
        LYRDWindowCloseAll = ':qa',
        LYRDWindowForceCloseAll = ':qa!',
        LYRDViewErrorList = '',
        LYRDViewRegisters = '',
        LYRDViewYankList = '',
        LYRDViewFileTree = '',
        LYRDViewFileExplorer = '',
        LYRDPluginsInstall = ':PlugInstall',
        LYRDPluginsUpdate = ':PlugClean',
        LYRDPluginsClean = ':PlugClean',
        LYRDTerminal = ':terminal',
    })
end

local function c(commandName)
    return ':'..commandName..'<CR>'
end

function L.keybindings(s)

    mappings.space_menu(s, {
        {{'g'}, 'Git Repository'},
        {{'a'}, 'Actions'},
        {{'A'}, 'Application'},
        {{'b'}, 'Buffers'},
        {{'f'}, 'Files'},
        {{'p'}, 'Plugins'},
        {{'q'}, 'Quit'},
        {{'s'}, 'Search'},
        {{'u'}, 'User interface'},
        {{'v'}, 'View'},
    })
    mappings.space(s,{
        {'n', {'v', 'l'}, c('LYRDViewErrorList'), 'List all errors'},
        {'n', {'v', 'r'}, c('LYRDViewRegisters'), 'Registers'},
        {'n', {'v', 'y'}, c('LYRDViewYankList'), 'Yank list'},
        {'n', {'<Tab>'}, c('LYRDBufferJumpToLast'), 'Jump to last buffer'},
        {'n', {'b', '>'}, c('LYRDBufferNext'), 'Next buffer'},
        {'n', {'b', '<'}, c('LYRDBufferPrev'), 'Previous buffer'},
        {'n', {'b', 'd'}, c('LYRDBufferClose'), 'Close buffer'},
        {'n', {'b', 'D'}, c('LYRDBufferForceClose'), 'Force close buffer'},
        {'n', {'b', 'x'}, c('LYRDBufferCloseAll'), 'Close all buffers'},
        {'n', {'b', 'f'}, c('LYRDBufferFormat'), 'Format document' },
        {'n', {'b', 'X'}, c('LYRDBufferForceCloseAll'), 'Force close all buffers'},
        {'n', {'b', 'h'}, c('LYRDBufferSplitH'), 'Horizonal split'},
        {'n', {'b', 'v'}, c('LYRDBufferSplitV'), 'Vertical split'},
        {'n', {'b', 'w'}, c('LYRDBufferSetReadOnly'), 'Toggle read only mode'},
        {'n', {'b', 'Y'}, c('LYRDBufferCopy'), 'Copy whole buffer to clipboard'},
        {'n', {'b', 'P'}, c('LYRDBufferPaste'), 'Paste clipboard to whole buffer'},
        {'n', {'b', 'n'}, c('LYRDBufferNew'), 'New empty buffer'},
        {'n', {'f', 's'}, c('LYRDBufferSave'), 'Save current file'},
        {'n', {'f', 'S'}, c('LYRDBufferSaveAll'), 'Save all files'},
        {'n', {'f', 't'}, c('LYRDViewFileTree'), 'Toggle file tree'},
        {'n', {'f', 'e'}, c('LYRDViewFileExplorer'), 'Explore files'},
        {'n', {'A', 'i'}, c('LYRDPluginsInstall'), 'Install plugins'},
        {'n', {'A', 'u'}, c('LYRDPluginsUpdate'), 'Update plugins'},
        {'n', {'A', 'c'}, c('LYRDPluginsClean'), 'Clean plugins'},
        {'n', {'A', 't'}, c('LYRDTerminal'), 'Terminal'},
        {'n', {'q', '.'}, c('LYRDWindowClose'), 'Close window'},
        {'n', {'q', 'q'}, c('LYRDWindowForceCloseAll'), 'Quit'},
        {'n', {'q', 'Q'}, c('LYRDWindowForceCloseAll'), 'Force Quit'},
        {'n', {'u', 'w'}, c('LYRDBufferToggleWrap'), 'Toggle line wrap'},
    })
end

return L
