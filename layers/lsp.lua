local setup = require 'setup'

local L = {
    name = 'LSP'
}

function L.plugins(s)
    setup.plugin(s, 'neovim/nvim-lspconfig')

end

function L.settings(s)
end

function L.keybindings(s)
end

function L.complete(s)
end

return L
