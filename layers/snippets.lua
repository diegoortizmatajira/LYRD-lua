local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"
local L = {name = 'Snippets'}

function L.plugins(s)
    setup.plugin(s, {'sirver/ultisnips', 'honza/vim-snippets'})
end

function L.settings(_)
    -- Setup lspconfig.
    lsp.plug_capabilities(function (previous_plug)
        return function ()
            local capabilities = previous_plug()
            capabilities.textDocument.completion.completionItem.snippetSupport = true;
            return capabilities
        end
    end)
end

function L.keybindings(s)
    vim.g.UltiSnipsExpandTrigger = "<c-j>"
    vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
end

return L
