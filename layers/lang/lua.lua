local lsp = require"LYRD.layers.lsp"

local L = {name = 'Lua Language'}

function L.plugins(_) end

function L.settings(_)
  local sumneko_root_path = '.'
  local sumneko_binary = '/usr/bin/lua-language-server'
  lsp.enable('sumneko_lua', {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';')
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'}
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
          }
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {enable = false}
      }
    }
  })
  -- Set Formatter for Autoformat
  vim.g.formatdef_my_custom_lua =
    '"lua-format -i --config ~/.config/nvim/lua/LYRD/configs/lua-format"'
  vim.g.formatters_lua = {'my_custom_lua'}
end

return L
