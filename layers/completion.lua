local mappings = require"LYRD.layers.mappings"
local setup = require"LYRD.setup"

local L = {name = 'Completion'}

function L.plugins(s)
  setup.plugin(s, {'hrsh7th/nvim-compe'})
end

function L.settings(_)

  vim.o.completeopt = "menuone,noinsert,noselect"

  require'compe'.setup{
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,
    source = {path = true, buffer = true, calc = true, nvim_lsp = true, nvim_lua = true, ultisnips = true}
  }

end

function L.keybindings(s)
  mappings.keys(s, {{'i', '<C-Space>', "compe#complete()"}}, {silent = true, expr = true, noremap = true})
end

return L
