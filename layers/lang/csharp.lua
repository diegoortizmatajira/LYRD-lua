local setup = require "LYRD.setup"
local lsp = require "LYRD.layers.lsp"

local L = {
    name = 'C# language'
}

function L.plugins(s)
    setup.plugin(s, {
     'OmniSharp/omnisharp-vim',
     'nickspoons/vim-sharpenup',
     'adamclerk/vim-razor'
    })

end

function L.settings(s)
    lsp.enable('omnisharp', {})
end

function L.keybindings(s)
end

function L.complete(s)
end

return L
