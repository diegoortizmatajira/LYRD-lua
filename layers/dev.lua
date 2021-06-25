local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"

local L = {name = 'Development'}

function L.plugins(s)
  setup.plugin(s, {
    'tpope/vim-commentary',
    'vim-autoformat/vim-autoformat',
    'norcalli/nvim-colorizer.lua',
    'steelsojka/pears.nvim'
  })
end

function L.settings(s)
  require'colorizer'.setup()
  require'pears'.setup(function(conf)
    conf.on_enter(function(pears_handle)
      if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
        return vim.fn["compe#confirm"]("<CR>")
      else
        pears_handle()
      end
    end)
  end)

  commands.implement(s, '*', {LYRDBufferFormat = ':Autoformat'})
end

return L
