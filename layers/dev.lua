local mappings = require"LYRD.layers.mappings"
local setup = require"LYRD.setup"

local L = {name = 'Development'}

function L.plugins(s)
  setup.plugin(s, {
    'tpope/vim-commentary',
    'vim-autoformat/vim-autoformat',
    'norcalli/nvim-colorizer.lua',
    'windwp/nvim-autopairs',
    'junegunn/vim-easy-align'
  })
end

function L.settings(_)
  require('colorizer').setup()
  require('nvim-autopairs').setup{}

end

function L.keybindings(s)
  mappings.keys(s, {{'x', 'ga', '<Plug>(EasyAlign)'}, {'n', 'ga', '<Plug>(EasyAlign)'}},
    {silent = true, noremap = false})
end

return L
