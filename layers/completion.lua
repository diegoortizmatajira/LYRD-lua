local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"

local L = {name = 'Completion'}

function L.plugins(s)
    setup.plugin(s, {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'quangnguyen30192/cmp-nvim-ultisnips',
        'tzachar/cmp-tabnine'
    })
end

function L.settings(_)

    -- vim.o.completeopt = "menuone,noinsert,noselect"
    vim.o.completeopt = "menu,menuone,noselect"

    local cmp = require'cmp'
    cmp.setup({
        snippet = {
            expand = function (args)
                vim.fn["UltiSnips#Anon"](args.body)
            end
        },
        mapping = {
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ['<C-e>'] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
            }),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'ultisnips' }, -- For ultisnips users.
            { name = 'cmp_tabnine'}
        }, {
                { name = 'buffer' },
            })
    })

    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline('/', {
        sources = {
            { name = 'buffer' }
        }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
                { name = 'cmdline' }
            })
    })

    -- Setup lspconfig.
    lsp.plug_capabilities(function (previous_capabilities)
        return function ()
            return require('cmp_nvim_lsp').update_capabilities(previous_capabilities())
        end
    end)

    local tabnine = require('cmp_tabnine.config')
    tabnine:setup({
        max_lines = 1000;
        max_num_results = 15;
        sort = true;
        run_on_every_keystroke = true;
        snippet_placeholder = '..';
        ignored_file_types = { -- default is not to ignore
            -- uncomment to ignore in lua:
            -- lua = true
        }
    })
end

return L
