local setup = require "LYRD.setup"

local L = {
    name = 'Debug'
}

function L.plugins(s)
    setup.plugin(s,
        {
            'Pocco81/DAPInstall.nvim',
            'mfussenegger/nvim-dap',
            'rcarriga/nvim-dap-ui',
            'nvim-telescope/telescope-dap.nvim',
            'theHamsta/nvim-dap-virtual-text',
        })
end

function L.settings(_)
    require("dapui").setup()
    vim.g.dap_virtual_text = true
end

function L.keybindings(_)
end

function L.complete(_)
    require('telescope').load_extension('dap')
end

return L
