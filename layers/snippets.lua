local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"
local L = {name = 'Snippets'}

function L.plugins(s)
    setup.plugin(s, {
        'L3MON4D3/LuaSnip',
        'honza/vim-snippets',
        'rafamadriz/friendly-snippets'
    })
end

function L.settings(_)
    -- local ls = require"luasnip"
    -- ls.filetype_extend("all", { "_" })
    -- require("luasnip/loaders/from_snipmate").lazy_load()
    require("luasnip/loaders/from_vscode").lazy_load()
    -- Setup lspconfig.
    lsp.plug_capabilities(function (previous_plug)
        return function ()
            local capabilities = previous_plug()
            capabilities.textDocument.completion.completionItem.snippetSupport = true;
            return capabilities
        end
    end)
end

function L.keybindings(_)
end

return L
