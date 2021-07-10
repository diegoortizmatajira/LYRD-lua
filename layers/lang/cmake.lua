local lsp = require"LYRD.layers.lsp"

local L = {name = 'CMake Language'}

function L.plugins(s)
end

function L.settings(s)
  lsp.enable('cmake', {})
end

function L.keybindings(s)
end

return L
