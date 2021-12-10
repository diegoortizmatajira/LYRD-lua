local lsp = require"LYRD.layers.lsp"

local L = {name = 'CMake Language'}

function L.plugins(_)
end

function L.settings(_)
    lsp.enable('cmake', {})
end

function L.keybindings(_)
end

return L
