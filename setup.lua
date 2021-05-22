if vim.g.LYRD_Settings == nil then
    vim.g.LYRD_Settings = {
        Loaded_layers = {}
    }
end


local function load_plugins(s, loaded_layers)
    vim.fn["plug#begin"](vim.fn.expand("~/.config/nvim/plugged"))

    for _, layer in ipairs(loaded_layers) do
        if layer.plugins ~= nil then
            layer.plugins(s)
        end
    end
    for k, v in pairs(s.plugins) do
        if v ~= "" then
            vim.cmd("Plug '"..k.."', "..v)
        else
            vim.cmd("Plug '"..k.."'")
        end
    end

    vim.fn["plug#end"]()
end

local function load_settings(s, loaded_layers)
    for _, layer in ipairs(loaded_layers) do
        if layer.settings ~= nil then
            layer.settings(s)
        end
    end
    for _, layer in ipairs(loaded_layers) do
        if layer.keybindings ~= nil then
            layer.keybindings(s)
        end
    end
end

local function load_complete(s, loaded_layers)
    for _, layer in ipairs(loaded_layers) do
        if layer.complete ~= nil then
            layer.complete(s)
        end
    end
end


return {
    load = function(s)
        s.plugins = {}
        local loaded_layers = {}
        local vim_layers = {}
        for _, layer in ipairs(s.layers) do
            local L = require(layer)
            table.insert(loaded_layers, L)
            table.insert(vim_layers, L.name)
        end
        --Updates LYRD_Settings in vim global
        local g_var = vim.g.LYRD_Settings
        g_var.Loaded_layers = vim_layers
        vim.g.LYRD_Settings = g_var
        -- Process each layer
        load_plugins(s, loaded_layers)
        load_settings(s, loaded_layers)
        load_complete(s, loaded_layers)
    end,

    -- Enables a plugin with its name and options
    plugin = function(s, plugin_list)
        for _ , p in ipairs(plugin_list) do
            local options = ''
            local plugin_name = ''
            if type(p) == 'string' then
                plugin_name = p
            else
                if #p > 1 then
                    options = p[2]
                end
                plugin_name = string.lower(p[1])
            end
            s.plugins[plugin_name] = options
        end
    end,

    register_layer = function (s, layer)
        table.insert(s.layers, layer)
    end
}
