local setup = require "setup"

LYRD_setup = {
    layers = {
        "layers.general",
        "layers.mappings",
        "layers.commands",
        "layers.keyboard",
        "layers.ui",
        "layers.filetree",
        "layers.dev",
        "layers.git",
        "layers.lsp",
        "layers.completion",
        "layers.treesitter",
        "layers.lang.go",
        "layers.lang.csharp",
        "layers.lang.lua",
        "layers.lang.python",
    },
}

setup.load(LYRD_setup)

