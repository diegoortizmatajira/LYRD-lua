local lsp = require"LYRD.layers.lsp"

local L = {name = 'Python language'}

function L.plugins(_)
end

function L.settings(_)
    lsp.enable('pyright', {})
end

function L.keybindings(_)
end

return L
