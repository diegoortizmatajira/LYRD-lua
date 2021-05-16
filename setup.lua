if vim.g.LYRD_Settings == nil then
    vim.g.LYRD_Settings = {
        plugins = {},
        layers = {}
    }
end

local api = vim.api
local M = {}

function load_plugins()
    vim.fn["plug#begin"](vim.fn.expand("~/.config/nvim/plugged"))

    for i, layer in ipairs(vim.g.LYRD_Settings.layers) do
        if layer.plugins ~= nil then
            layer.plugins()
        end
    end
    for k, v in pairs(vim.g.LYRD_Settings.plugins) do
        if v ~= "" then
            vim.cmd("Plug '"..k.."', "..v)
        else
            vim.cmd("Plug '"..k.."'")
        end
    end

    vim.fn["plug#end"]()
end

function load_settings()
    for i, layer in ipairs(vim.g.LYRD_Settings.layers) do
        if layer.settings ~= nil then
            layer.settings()
        end
        if layer.keybindings ~= nil then
            layer.keybindings()
        end
    end
end

function load_complete()
    for i, layer in ipairs(vim.g.LYRD_Settings.layers) do
        if layer.complete ~= nil then
            layer.complete()
        end
    end
end

function M.load()
    load_plugins()
    load_settings()
    load_complete()
end

-- Enables a plugin with its name and options
function M.plugin(plugin_name, options)
    options = options or ""
    plugin_name = string.lower(plugin_name)
    local plugins = vim.g.LYRD_Settings.plugins
    plugins[plugin_name] = options
    vim.g.LYRD_Settings.plugins = plugins
end

function M.register_layer(layer_name)
    local layers = vim.g.LYRD_Settings.layers
    table.insert(layers, layer_name)
    vim.g.LYRD_Settings.layers = layers
end

return M
