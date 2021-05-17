local setup = require "setup"

LYRD_setup = {
    plugins = {},
    layers = {
        "layers.general",
        "layers.lsp",
        "layers.lang.go",
        "layers.lang.csharp",
        --  "layers.core",
        --  "layers.motions",
        --  "layers.treesitter",
        --  "layers.fzf",
        --  "layers.git",
        --  "layers.coc",
        --  "layers.wiki",
        --  "layers.ui",
    },
}

setup.load(LYRD_setup)

