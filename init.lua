local setup = require "setup"

LYRD_setup = {
    layers = {
        "layers.general",
        "layers.mappings",
        "layers.commands",
        "layers.lyrd-commands",
        "layers.lyrd-ui",
        "layers.lyrd-keyboard",
        "layers.motions",
        "layers.dev",
        "layers.git",
        "layers.lsp",
        "layers.treesitter",
        "layers.filetree",
        "layers.telescope",
        "layers.completion",
        "layers.lang.go",
        "layers.lang.csharp",
        "layers.lang.lua",
        "layers.lang.python"
    }
}

setup.load(LYRD_setup)
