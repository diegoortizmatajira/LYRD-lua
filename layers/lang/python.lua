local lsp = require"LYRD.layers.lsp"
local setup = require "LYRD.setup"

local L = {name = 'Python language'}

function L.plugins(s)
    setup.plugin(s,
        {
            -- 'mfussenegger/nvim-dap-python'
        })
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
