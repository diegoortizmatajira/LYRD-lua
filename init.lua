local setup = require "setup"

LYRD_setup = {
    plugins = {},
    layers = {
        "layers.general",
        "layers.ui",
        "layers.git",
        "layers.lsp",
        "layers.treesitter",
        "layers.lang.go",
        "layers.lang.csharp",
    },
}

setup.load(LYRD_setup)

