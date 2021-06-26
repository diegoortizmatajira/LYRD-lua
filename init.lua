local setup = require "LYRD.setup"

_G.LYRD_setup = {
    layers = {
        "LYRD.layers.general",
        "LYRD.layers.mappings",
        "LYRD.layers.commands",
        "LYRD.layers.shared-key-handlers",
        "LYRD.layers.lyrd-commands",
        "LYRD.layers.lyrd-ui",
        "LYRD.layers.lyrd-keyboard",
        "LYRD.layers.motions",
        "LYRD.layers.dev",
        "LYRD.layers.git",
        "LYRD.layers.lsp",
        "LYRD.layers.treesitter",
        "LYRD.layers.filetree",
        "LYRD.layers.telescope",
        "LYRD.layers.snippets", -- Before completion
        "LYRD.layers.completion",
        "LYRD.layers.lang.go",
        "LYRD.layers.lang.csharp",
        "LYRD.layers.lang.lua",
        "LYRD.layers.lang.python"
    }
}

setup.load(_G.LYRD_setup)
