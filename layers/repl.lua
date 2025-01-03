local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local handler = commands.handler
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = {
    name = "REPL",
    -- Add as many filetypes as you have iron.nvim configured to support REPL
    supported_filetypes = { "python" },
}

function L.plugins(s)
    setup.plugin(s, {
        {
            -- Enables REPL processing
            "vigemus/iron.nvim",
            opts = {
                config = {
                    repl_open_cmd = "horizontal bot 20 split",
                    repl_definition = {
                        python = {
                            command = function()
                                -- Tries to check if IPython, Python or Python3 are available in that specific order.
                                local ipythonAvailable = vim.fn.executable("ipython") == 1
                                local pythonAvailable = vim.fn.executable("python") == 1
                                local binary = (ipythonAvailable and "ipython")
                                    or (pythonAvailable and "python")
                                    or "python3"
                                return { binary }
                            end,
                        },
                    },
                },
            },
            main = "iron.core",
        },
        {
            -- Enables notebook like mode
            "GCBallesteros/NotebookNavigator.nvim",
            dependencies = {
                "echasnovski/mini.comment",
                "vigemus/iron.nvim", -- repl provider
            },
            event = "VeryLazy",
            opts = {},
        },
        {
            "echasnovski/mini.hipatterns",
            event = "VeryLazy",
            dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
            opts = function()
                local nn = require("notebook-navigator")
                local opts = { highlighters = { cells = nn.minihipatterns_spec } }
                return opts
            end,
        },
    })
end

function L.settings(s)
    local nn = require("notebook-navigator")
    commands.implement(s, L.supported_filetypes, {
        { cmd.LYRDReplView,                   ":IronRepl" },
        { cmd.LYRDReplRestart,                ":IronRestart" },
        { cmd.LYRDReplNotebookRunCell,        nn.run_cell },
        { cmd.LYRDReplNotebookRunCellAndMove, nn.run_and_move },
        { cmd.LYRDReplNotebookRunAllCells,    nn.run_all_cells },
        -- { cmd.LYRDReplNotebookRunAllAbove, nn.run },
        { cmd.LYRDReplNotebookRunAllBelow,    nn.run_cells_below },
        { cmd.LYRDReplNotebookMoveCellUp,     handler(nn.move_cell, "u") },
        { cmd.LYRDReplNotebookMoveCellDown,   handler(nn.move_cell, "d") },
        { cmd.LYRDReplNotebookAddCellAbove,   nn.add_cell_above },
        { cmd.LYRDReplNotebookAddCellBelow,   nn.add_cell_below },
    })
end

return L
