local lsp = require"LYRD.layers.lsp"

local L = {name = 'Python language'}

function L.plugins(_)
end

function L.settings(_)
end

function L.keybindings(_)
end

function L.complete(_)
    lsp.enable('pyright', {
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "off"
                }
            }
        },
    })
end


return L
