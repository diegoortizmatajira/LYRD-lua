local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Development" }

function L.plugins()
    setup.plugin({
        {
            "folke/todo-comments.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
            opts = {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            },
        },
        {
            "danymat/neogen",
            config = {
                snippet_engine = "luasnip",
            },
        },
        {
            "stevearc/aerial.nvim",
            opts = {
                close_on_select = true,
            },
            -- Optional dependencies
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
                "nvim-tree/nvim-web-devicons",
            },
            cmd = { "AerialToggle" },
        },
        { "norcalli/nvim-colorizer.lua" },
        {
            "ellisonleao/dotenv.nvim",
            opts = {},
            cmd = { "Dotenv", "DotenvGet" },
        },
        { -- This plugin
            "zeioth/compiler.nvim",
            cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
            dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
            opts = {},
        },
        {
            "Zeioth/makeit.nvim",
            cmd = { "MakeitOpen", "MakeitToggleResults", "MakeitRedo" },
            dependencies = { "stevearc/overseer.nvim" },
            opts = {},
        },
    })
end

function L.settings()
    commands.implement("*", {
        { cmd.LYRDViewCodeOutline,      ":AerialToggle" },
        { cmd.LYRDCodeMakeTasks,        ":MakeitOpen" },
        { cmd.LYRDCodeAddDocumentation, ":Neogen" },
    })
end

return L
