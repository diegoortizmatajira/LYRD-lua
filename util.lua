local fn, api = vim.fn, vim.api

_G.Util = {}

Util.check_backspace = function()
  local curr_col = fn.col(".")
  local is_first_col = fn.col(".") - 1 == 0
  local prev_char = fn.getline("."):sub(curr_col - 1, curr_col - 1)

  return (is_first_col or prev_char:match("%s") == " ")
end

Util.trigger_completion = function()
  if fn.pumvisible() ~= 0 and fn.complete_info()["selected"] ~= -1 then return fn["compe#confirm"]() end

  local prev_col, next_col = fn.col(".") - 1, fn.col(".")
  local prev_char = fn.getline("."):sub(prev_col, prev_col)
  local next_char = fn.getline("."):sub(next_col, next_col)

  -- minimal autopairs-like behaviour
  if prev_char == "{" and next_char ~= "}" then return Util.t("<CR>}<C-o>O") end
  if prev_char == "[" and next_char ~= "]" then return Util.t("<CR>]<C-o>O") end
  if prev_char == "(" and next_char ~= ")" then return Util.t("<CR>)<C-o>O") end
  if prev_char == ">" and next_char == "<" then return Util.t("<CR><C-o>O") end -- html indents
  if prev_char == "(" and next_char == ")" then return Util.t("<CR><C-o>O") end -- flutter indents

  return api.nvim_replace_termcodes("<CR>", true, true, true)
end

return Util
