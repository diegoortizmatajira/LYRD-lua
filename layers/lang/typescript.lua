local lsp = require"LYRD.layers.lsp"

local L = {name = 'TypeScript Language'}

function L.plugins(s)
end

function L.settings(s)
  lsp.enable('tsserver', {})
end

function L.keybindings(s)
end

return L
