local setup = require"LYRD.setup"
local L = {name = 'Snippets'}

function L.plugins(s)
  setup.plugin(s, {'sirver/ultisnips', 'honza/vim-snippets'})
end

function L.settings(_)
end

function L.keybindings(s)
  vim.g.UltiSnipsExpandTrigger = "<c-j>"
  vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
  vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"

  s.SharedExpressions.Tab.snippets = function()
    if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 or vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
      return vim.api.nvim_replace_termcodes("<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>")
    else
      return nil
    end
  end

  s.SharedExpressions.Shift_Tab.snippets = function()
    if vim.fn["UltiSnips#CanJumpBackwards"] == 1 then
      return vim.api.nvim_replace_termcodes("<C-R>=UltiSnips#JumpBackwards()<CR>")
    else
      return nil
    end
  end
end

return L
