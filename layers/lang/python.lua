local lsp = require"LYRD.layers.lsp"

local L = {name = 'Python language'}

function L.plugins(s)
end

function L.settings(s)
  require'lspconfig'.pyright.setup{}
end

function L.keybindings(s)
end

return L
