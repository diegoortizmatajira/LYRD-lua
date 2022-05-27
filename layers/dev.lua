local mappings = require"LYRD.layers.mappings"
local setup = require"LYRD.setup"

local L = {name = 'Development'}

function L.plugins(s)
  setup.plugin(s, {'tpope/vim-commentary', 'norcalli/nvim-colorizer.lua', 'windwp/nvim-autopairs'})
end

function L.settings(_)
  require('colorizer').setup()
  require('nvim-autopairs').setup{}

end

return L
