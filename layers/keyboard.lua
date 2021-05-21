local mappings = require "layers.mappings"

local L = {
    name = 'Keyboard'
}

function L.plugins(s)
end

function L.settings(s)
end

function L.keybindings(s)
    mappings.keys(s, {
        {'n', '<C-s>', [[:w<CR>]]},
        {'i', '<C-s>', [[<Esc>:w<CR>]]},
    })
    mappings.space(s, {
        {'n', {'b', 'f'}, ':Autoformat<CR>', 'Formatear' }
    })
end

function L.complete(s)
end

return L
