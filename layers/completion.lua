local setup = require "setup"

local L = {
    name = 'Completion'
}

function L.plugins(s)

    setup.plugin(s,
        {
            'hrsh7th/nvim-compe',
        })
end

function L.settings(s)
    require'compe'.setup {
        enabled = true;
        autocomplete = true;
        debug = false;
        min_length = 1;
        preselect = 'enable';
        throttle_time = 80;
        source_timeout = 200;
        incomplete_delay = 400;
        max_abbr_width = 100;
        max_kind_width = 100;
        max_menu_width = 100;
        documentation = true;

        source = {
            path = true;
            buffer = true;
            calc = true;
            nvim_lsp = true;
            nvim_lua = true;
            vsnip = true;
            ultisnips = true;
        };
    }
end

function L.keybindings(s)
end

function L.complete(s)
end

return L
