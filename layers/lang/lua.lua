local setup = require "setup"

local L = {name = 'Lua Language'}

function L.plugins(s) end

function L.settings(s)
    local sumneko_root_path = '.'
    local sumneko_binary = '/usr/bin/lua-language-server'
    require'lspconfig'.sumneko_lua.setup {
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
    }
    -- Set Formatter for Autoformat
    vim.g.formatdef_my_custom_lua =
        '"lua-format --column-limit=150 --align-table-field --break-after-table-lb --break-before-table-rb --chop-down-table --chop-down-kv-table"'
    vim.g.formatters_lua = {'my_custom_lua'}
end

function L.keybindings(s) end

function L.complete(s) end

return L
