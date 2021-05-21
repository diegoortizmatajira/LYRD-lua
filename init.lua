local setup = require "setup"

LYRD_setup = {
    plugins = {},
    layers = {
        "layers.general",
        "layers.commands",
        "layers.ui",
        "layers.filetree",
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

