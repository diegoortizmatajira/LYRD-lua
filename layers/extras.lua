local setup = require("LYRD.setup")

local L = { name = "Extras" }

function L.plugins(s)
    setup.plugin(s, {
        {
            -- Enables hardtime constraints to improve VIM motions use
            "m4xshen/hardtime.nvim",
            dependencies = { "muniftanjim/nui.nvim" },
            opts = {
                disable_mouse = false,
                restricted_keys = {
                    ["h"] = { "n", "x" },
                    ["j"] = { "n", "x" },
                    ["k"] = { "n", "x" },
                    ["l"] = { "n", "x" },
                    ["+"] = { "n", "x" },
                    ["gj"] = { "n", "x" },
                    ["gk"] = { "n", "x" },
                    ["<C-M>"] = { "n", "x" },
                    ["<C-N>"] = { "n", "x" },
                    ["<C-P>"] = { "n", "x" },
                    ["<Up>"] = { "n", "i" },
                    ["<Down>"] = { "n", "i" },
                    ["<Left>"] = { "n", "i" },
                    ["<Right>"] = { "n", "i" },
                },
                disabled_keys = {
                    ["<Up>"] = {},
                    ["<Down>"] = {},
                    ["<Left>"] = {},
                    ["<Right>"] = {},
                },
            },
        },
    })
end

return L
