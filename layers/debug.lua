local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Debug" }

function L.plugins(s)
    setup.plugin(s, {
        "pocco81/dapinstall.nvim",
        "mfussenegger/nvim-dap",
        { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } },
        "nvim-telescope/telescope-dap.nvim",
        "theHamsta/nvim-dap-virtual-text",
    })
end

function L.settings(s)
    require("dapui").setup()
    vim.g.dap_virtual_text = true
    commands.implement(s, "*", {
        { cmd.LYRDDebugBreakpoint, ":DapToggleBreakpoint" },
        { cmd.LYRDDebugContinue,   ":DapContinue" },
        { cmd.LYRDDebugStepInto,   ":DapStepInto" },
        { cmd.LYRDDebugStepOver,   ":DapStepOver" },
        { cmd.LYRDDebugStop,       ":DapTerminate" },
        { cmd.LYRDDebugToggleUI,   require("dapui").toggle },
        { cmd.LYRDDebugToggleRepl, ":DapToggleRepl" },
    })
end

function L.keybindings(_) end

function L.complete(_)
    require("telescope").load_extension("dap")
end

return L
