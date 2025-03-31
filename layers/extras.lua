local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Extras" }

function L.plugins()
    setup.plugin({
        {
            -- Enables hardtime constraints to improve VIM motions use
            "m4xshen/hardtime.nvim",
            dependencies = { "muniftanjim/nui.nvim" },
            opts = {
                enabled = false,
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
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            ---@type snacks.Config
            opts = {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                -- bigfile = { enabled = true },
                -- dashboard = { enabled = true },
                -- explorer = { enabled = true },
                -- indent = { enabled = true },
                image = {},
                -- input = { enabled = true },
                -- picker = { enabled = true },
                -- notifier = { enabled = true },
                -- quickfile = { enabled = true },
                -- scope = { enabled = true },
                -- scroll = { enabled = true },
                -- statuscolumn = { enabled = true },
                -- words = { enabled = true },
            },
        },
    })
end

function L.settings()
    commands.implement("*", {
        { cmd.LYRDHardModeToggle, ":Hardtime toggle" },
        {
            cmd.LYRDGitBrowseOnWeb,
            function()
                require("snacks").gitbrowse()
            end,
        },
    })
end

return L
