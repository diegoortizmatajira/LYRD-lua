local setup = require "setup"

local L = {
    name = 'Go language'
}

function L.plugins(s)
end

function L.settings(s)
    require 'lspconfig'.gopls.setup{}
end

function L.keybindings(s)
end

function L.complete(s)
end

return L
