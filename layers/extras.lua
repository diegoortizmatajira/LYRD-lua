local setup = require("LYRD.setup")

local L = { name = "Extras" }

function L.plugins(s)
    setup.plugin(s, {
        {
            -- Enables hardtime constraints to improve VIM motions use
            "m4xshen/hardtime.nvim",
            dependencies = { "muniftanjim/nui.nvim" },
            opts = {},
        },
    })
end

return L
