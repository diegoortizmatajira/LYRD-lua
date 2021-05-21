local setup = require "setup"

local L = {
    name = 'Mappings'
}

function L.plugins(s)
    setup.plugin(s,
        {
            {'liuchengxu/vim-which-key'},
        })
end

function L.settings(s)
    s.mappings = {
        Leader = {},
        Space = {},
    }
    vim.g.which_key_timeout = 100
end

function L.keybindings(s)
    L.keys(s, {
        {'n', '<Leader>', [[:WhichKey '<Leader>'<CR>]]},
        {'n', '<Space>', [[:WhichKey '<Space>'<CR>]]},
    })
end

function L.complete(s)
    --Updates LYRD_Settings in vim global
    local g_var = vim.g.LYRD_Settings
    g_var.mappings = s.mappings
    vim.g.LYRD_Settings = g_var
    vim.cmd("call which_key#register(',', g:LYRD_Settings.mappings.Leader)")
    vim.cmd("call which_key#register('<Space>', g:LYRD_Settings.mappings.Space)")
end

local function recursive_documentation(mapping_tree, keys, documentation, depth)
    if depth == #keys then
        mapping_tree[keys[depth]] = documentation
    else
        if mapping_tree[keys[depth]] == nil then
            mapping_tree[keys[depth]] = {
                ['_'] = '', --Placeholder
            }
        end
        if type(mapping_tree[keys[depth]]) ~= 'table' then
            local collapsedkeys = {}
            for i= 1, #keys do
                if i <= depth then
                    table.insert(collapsedkeys, keys[i])
                else
                    collapsedkeys[depth] = collapsedkeys[depth]..keys[i]
                end
            end
            -- The next iteration would produce and error as the next node is not a dictionary
            recursive_documentation(mapping_tree, collapsedkeys, description, depth)
        else
            recursive_documentation(mapping_tree[keys[depth]], keys, description, depth+1)
        end
    end
end

local function map_key(s, mode, lead, keys, command, documentation, options)
    if options == nil then
        options = {
            noremap = true,
            silent = true
        }
    end
    if lead ~= nil then
        recursive_documentation(s.mappings[lead], keys, documentation, 1)
        lead = '<'..lead..'>'
    else
        lead = ''
    end
    local key_str = lead..table.concat(keys)
    vim.api.nvim_set_keymap(mode, key_str, command, options)
end

local function map_menu(s, lead, keys, description )
    recursive_documentation(s.mappings[lead], keys, {name = '['..description..']'}, 1)
end

function L.keys(s, mappings)
    for _, mapping in ipairs(mappings) do
        map_key(s, mapping[1], nil, {mapping[2]}, mapping[3])
    end
end

function L.leader(s, mappings)
    for _, mapping in ipairs(mappings) do
        map_key(s, mapping[1], 'Leader', mapping[2], mapping[3], mapping[4], mapping[5])
    end
end

function L.space(s, mappings)
    for _, mapping in ipairs(mappings) do
        map_key(s, mapping[1], 'Space', mapping[2], mapping[3], mapping[4], mapping[5])
    end
end

function L.space_menu(s, mappings)
    for _, mapping in ipairs(mappings) do
        map_menu(s, 'Space', mapping[1], mapping[2])
    end
end

function L.leader_ignore_key(keys)
    recursive_documentation(s.mappings['Leader'], keys, 'which_key_ignore', 1)
end

function L.leader_ignore_menu(keys)
    recursive_documentation(s.mappings['Leader'], keys,  {name = 'which_key_ignore'}, 1)
end

return L
