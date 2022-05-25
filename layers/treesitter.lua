local setup = require"LYRD.setup"

local L = {name = 'Treesitter'}

function L.plugins(s)
  setup.plugin(s, {{'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}, 'nvim-treesitter/playground'})
end

function L.settings(_)
  require'nvim-treesitter.configs'.setup{
    highlight = {enable = true},
    incremental_selection = {
      enable = true,
      keymaps = {init_selection = "gnn", node_incremental = "grn", scope_incremental = "grc", node_decremental = "grm"}
    },
    indent = {enable = true}
  }
end

return L
