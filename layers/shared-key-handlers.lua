local mappings = require"LYRD.layers.mappings"

local L = {name = 'Shared Key Handlers'}

local check_backspace = function()
  local curr_col = vim.fn.col(".")
  local is_first_col = vim.fn.col(".") - 1 == 0
  local prev_char = vim.fn.getline("."):sub(curr_col - 1, curr_col - 1)

  return (is_first_col or prev_char:match("%s") == " ")
end

local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

L.LYRD_enter_handler = function(old_handler)
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
    return vim.fn["compe#confirm"]("<CR>")
  else
    return old_handler()
  end
end

L.LYRD_tab_handler = function(old_handler)
  if vim.fn.pumvisible() == 1 then
    return vim.fn["compe#confirm"]("<Tab>")
  elseif vim.fn["UltiSnips#CanExpandSnippet"]() == 1 or vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
    return t("<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>")
  elseif check_backspace() then
    return old_handler()
  else
    return vim.fn['compe#complete']()
  end
end

L.LYRD_shift_tab_handler = function(old_handler)
  if vim.fn["UltiSnips#CanJumpBackwards"] == 1 then
    return t("<C-R>=UltiSnips#JumpBackwards()<CR>")
  else
    return old_handler()
  end
end

function L.settings(s)
  _G.LYRD_TabExpression = function()
    return L.LYRD_tab_handler(function()
      return t('<Tab>')
    end)
  end
  _G.LYRD_ShiftTabExpression = function()
    return L.LYRD_shift_tab_handler(function()
      return t('<S-Tab>')
    end)
  end

end

function L.keybindings(s)
  mappings.keys(s, {
    {"i", "<Tab>", [[v:lua.LYRD_TabExpression()]]},
    {"s", "<Tab>", [[v:lua.LYRD_TabExpression()]]},
    {"i", "<S-Tab>", [[v:lua.LYRD_ShiftTabExpression()]]},
    {"s", "<S-Tab>", [[v:lua.LYRD_ShiftTabExpression()]]}
  }, {silent = true, expr = true, noremap = true})
end

return L
