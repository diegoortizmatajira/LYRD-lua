local setup = require"LYRD.setup"
local lsp = require"LYRD.layers.lsp"

local L = {name = 'Completion'}

local kind_icons = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
}

local menu_texts ={
    luasnip = "[Snippet]",
    ultisnips = "[Snippet]",
    buffer = "[Buffer]",
    path = "[Path]",
    cmp_tabnine = "[Tab-9]"
}

function L.plugins(s)
    setup.plugin(s, {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'saadparwaiz1/cmp_luasnip',
        'tzachar/cmp-tabnine'
    })
end

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

function L.settings(_)

    local luasnip_ok, luasnip = pcall(require,"luasnip")
    if not luasnip_ok then
        return
    end
    -- vim.o.completeopt = "menuone,noinsert,noselect"
    vim.o.completeopt = "menu,menuone,noselect"

    local cmp = require'cmp'
    cmp.setup({
        snippet = {
            expand = function (args)
                luasnip.lsp_expand(args.body)
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
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" }),

            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        },
        formatting = {
            fields = { "abbr", "kind", "menu" },
            format = function(entry, vim_item)
                -- Kind icons
                vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind],vim_item.kind)
                vim_item.menu = menu_texts[entry.source.name]
                return vim_item
            end,
        },
        sources = cmp.config.sources({
            { name = 'ultisnips' },
            { name = 'nvim_lsp' },
            { name = 'luasnip'},
            { name = 'buffer' },
        }),
        confirm_opts = {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        experimental = {
            ghost_text = true,
            native_menu = false,
        },
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
