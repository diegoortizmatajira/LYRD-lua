local lsp = require"LYRD.layers.lsp"

local L = {name = 'CMake Language'}

function L.plugins(_)
end

function L.settings(_)
end

function L.keybindings(_)
end

function L.complete(_)
    lsp.enable('cmake', {})
end

return L
