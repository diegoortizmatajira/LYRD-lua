local setup = require"LYRD.setup"
local mappings = require"LYRD.layers.mappings"

local L = {name = 'Completion'}

function L.plugins(s)
  setup.plugin(s, {'hrsh7th/nvim-compe'})
end

local check_backspace = function()
  local curr_col = vim.fn.col(".")
  local is_first_col = vim.fn.col(".") - 1 == 0
  local prev_char = vim.fn.getline("."):sub(curr_col - 1, curr_col - 1)

  return (is_first_col or prev_char:match("%s") == " ")
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
  s.SharedExpressions.Enter.completion = function()
    if vim.fn.pumvisible() == 1 and vim.fn.complete_info()["selected"] ~= -1 then
      return vim.fn["compe#confirm"]('<CR>')
    else
      return nil
    end
  end

  s.SharedExpressions.Tab.completion = function()
    if vim.fn.pumvisible() == 1 then
      return vim.fn["compe#confirm"]('<Tab>')
    elseif check_backspace() then
      return nil
    else
      return vim.fn['compe#complete']()
    end
  end

  mappings.keys(s, {{'i', '<C-Space>', "compe#complete()"}}, {silent = true, expr = true, noremap = true})
end
return L
