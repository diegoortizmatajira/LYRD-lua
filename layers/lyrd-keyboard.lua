local mappings = require "layers.mappings"

local L = {
    name = 'LYRD Keyboard'
}

function L.plugins(s)
end

function L.settings(s)
end

function L.keybindings(s)
    mappings.keys(s, {
        {'n', '<C-s>', ':LYRDBufferSave<CR>'},
        {'i', '<C-s>', '<Esc>:LYRDBufferSave<CR>'},
    })
end

function L.complete(s)
end

return L
