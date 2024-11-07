local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Completion" }

local kind_icons = {
    Class = " ",
    Color = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Operator = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
}

local menu_texts = {
    buffer = "[Buffer]",
    calc = "[Calc]",
    cmp_tabnine = "[Tabnine]",
    copilot = "[Copilot]",
    emoji = "[Emoji]",
    luasnip = "[Snippet]",
    nvim_lsp = "[LSP]",
    path = "[Path]",
    tmux = "[TMUX]",
    treesitter = "[TreeSitter]",
    vsnip = "[Snippet]",
}

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function jumpable(dir)
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if not luasnip_ok then
        return false
    end

    local win_get_cursor = vim.api.nvim_win_get_cursor
    local get_current_buf = vim.api.nvim_get_current_buf

    ---sets the current buffer's luasnip to the one nearest the cursor
    ---@return boolean true if a node is found, false otherwise
    local function seek_luasnip_cursor_node()
        -- TODO(kylo252): upstream this
        -- for outdated versions of luasnip
        if not luasnip.session.current_nodes then
            return false
        end

        local node = luasnip.session.current_nodes[get_current_buf()]
        if not node then
            return false
        end

        local snippet = node.parent.snippet
        local exit_node = snippet.insert_nodes[0]

        local pos = win_get_cursor(0)
        pos[1] = pos[1] - 1

        -- exit early if we're past the exit node
        if exit_node then
            local exit_pos_end = exit_node.mark:pos_end()
            if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
                snippet:remove_from_jumplist()
                luasnip.session.current_nodes[get_current_buf()] = nil

                return false
            end
        end

        node = snippet.inner_first:jump_into(1, true)
        while node ~= nil and node.next ~= nil and node ~= snippet do
            local n_next = node.next
            local next_pos = n_next and n_next.mark:pos_begin()
            local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
                or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

            -- Past unmarked exit node, exit early
            if n_next == nil or n_next == snippet.next then
                snippet:remove_from_jumplist()
                luasnip.session.current_nodes[get_current_buf()] = nil

                return false
            end

            if candidate then
                luasnip.session.current_nodes[get_current_buf()] = node
                return true
            end

            local ok
            ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
            if not ok then
                snippet:remove_from_jumplist()
                luasnip.session.current_nodes[get_current_buf()] = nil

                return false
            end
        end

        -- No candidate, but have an exit node
        if exit_node then
            -- to jump to the exit node, seek to snippet
            luasnip.session.current_nodes[get_current_buf()] = snippet
            return true
        end

        -- No exit node, exit from snippet
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil
        return false
    end

    if dir == -1 then
        return luasnip.in_snippet() and luasnip.jumpable(-1)
    else
        return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
    end
end

function L.plugins(s)
    setup.plugin(s, {
        {
            "hrsh7th/nvim-cmp",
            config = function()
                local cmp = require("cmp")
                local cmp_mapping = require("cmp.config.mapping")
                local luasnip = require("luasnip")

                local status_cmp_ok, cmp_types = pcall(require, "cmp.types.cmp")
                if not status_cmp_ok then
                    return
                end
                local ConfirmBehavior = cmp_types.ConfirmBehavior
                local SelectBehavior = cmp_types.SelectBehavior
                cmp.setup({
                    mapping = cmp_mapping.preset.insert({
                        ["<Down>"] = cmp_mapping(
                            cmp.mapping.select_next_item({ behavior = SelectBehavior.Select }),
                            { "i" }
                        ),
                        ["<Up>"] = cmp_mapping(
                            cmp.mapping.select_prev_item({ behavior = SelectBehavior.Select }),
                            { "i" }
                        ),
                        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-f>"] = cmp.mapping.scroll_docs(4),
                        ["<C-y>"] = cmp_mapping({
                            i = cmp_mapping.confirm({ behavior = ConfirmBehavior.Replace, select = false }),
                            c = function(fallback)
                                if cmp.visible() then
                                    cmp.confirm({ behavior = ConfirmBehavior.Replace, select = false })
                                else
                                    fallback()
                                end
                            end,
                        }),
                        ["<Tab>"] = cmp_mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.expand_or_locally_jumpable() then
                                luasnip.expand_or_jump()
                            elseif jumpable(1) then
                                luasnip.jump(1)
                            elseif has_words_before() then
                                -- cmp.complete()
                                fallback()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<S-Tab>"] = cmp_mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<C-Space>"] = cmp_mapping.complete(),
                        ["<C-e>"] = cmp_mapping.abort(),
                        ["<CR>"] = cmp_mapping(function(fallback)
                            if cmp.visible() then
                                local confirm_opts = {
                                    behavior = ConfirmBehavior.Replace,
                                    select = false,
                                }
                                local is_insert_mode = function()
                                    return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
                                end
                                if is_insert_mode() then -- prevent overwriting brackets
                                    confirm_opts.behavior = ConfirmBehavior.Insert
                                end
                                local entry = cmp.get_selected_entry()
                                local is_copilot = entry and entry.source.name == "copilot"
                                if is_copilot then
                                    confirm_opts.behavior = ConfirmBehavior.Replace
                                    confirm_opts.select = true
                                end
                                if cmp.confirm(confirm_opts) then
                                    return -- success, exit early
                                end
                            end
                            fallback() -- if not exited early, always fallback
                        end),
                    }),
                    formatting = {
                        fields = { "abbr", "kind", "menu" },
                        format = function(entry, vim_item)
                            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
                            vim_item.menu = menu_texts[entry.source.name]
                            return vim_item
                        end,
                    },
                    snippet = {
                        expand = function(args)
                            require("luasnip").lsp_expand(args.body)
                        end,
                    },
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "buffer" },
                        { name = "luasnip" },
                        { name = "cmp_tabnine" },
                        { name = "path" },
                        { name = "nvim_lsp_signature_help" },
                        { name = "cmp-dbee" },
                        { name = "tmux" },
                    }),
                })

                cmp.setup.cmdline({ "/", "?" }, {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = {
                        { name = "buffer" },
                    },
                })

                cmp.setup.cmdline(":", {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({
                        { name = "path" },
                    }, {
                        { name = "cmdline" },
                    }),
                    matching = { disallow_symbol_nonprefix_matching = false },
                })
            end,
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "saadparwaiz1/cmp_luasnip",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-nvim-lsp-signature-help",
                "hrsh7th/cmp-cmdline",
                "MattiasMTS/cmp-dbee",
            },
        },
        {
            "hrsh7th/cmp-nvim-lsp",
            config = function()
                lsp.plug_capabilities(function(previous_capabilities)
                    return function()
                        return require("cmp_nvim_lsp").default_capabilities(previous_capabilities())
                    end
                end)
            end,
        },
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "andersevenrud/cmp-tmux",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "mattn/emmet-vim",
        "MattiasMTS/cmp-dbee",
        {
            "tzachar/cmp-tabnine",
            opts = {
                max_lines = 1000,
                max_num_results = 20,
                sort = true,
                run_on_every_keystroke = true,
                snippet_placeholder = "..",
                ignored_file_types = {
                    -- default is not to ignore
                    -- uncomment to ignore in lua:
                    -- lua = true
                },
                show_prediction_strength = false,
                min_percent = 0,
            },
            build = "./install.sh",
            dependencies = "hrsh7th/nvim-cmp",
        },
    })
end

function L.settings(_)
    vim.o.completeopt = "menu,preview,menuone,noselect"
end

return L
