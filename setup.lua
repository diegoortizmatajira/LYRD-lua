local utils = require("LYRD.utils")

---@alias LYRD.setup.Settings { layers:string[], plugins?:string[]}

---@class LYRD.setup.Module
---@field name string
---@field plugins? nil|fun(s):nil
---@field preparation? nil|fun(s):nil
---@field settings? nil|fun(s):nil
---@field keybindings? nil|fun(s):nil
---@field complete? nil|fun(s):nil

local setup = {
	configs_path = utils.get_lyrd_path() .. "/configs",
	runtime_path = utils.get_lyrd_path() .. "/runtime",
}

if vim.g.LYRD_Settings == nil then
	vim.g.LYRD_Settings = { Loaded_layers = {} }
end

local function bootstrap_lazy()
	-- Bootstrap lazy.nvim
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not (vim.uv or vim.loop).fs_stat(lazypath) then
		local lazyrepo = "https://github.com/folke/lazy.nvim.git"
		local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
		if vim.v.shell_error ~= 0 then
			vim.api.nvim_echo({
				{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
				{ out, "WarningMsg" },
				{ "\nPress any key to exit..." },
			}, true, {})
			vim.fn.getchar()
			os.exit(1)
		end
	end
	vim.opt.rtp:prepend(lazypath)
end

--- Calls the plugin method for each layer
---@param s LYRD.setup.Settings settings object
---@param loaded_layers  LYRD.setup.Module[]
local function load_plugins(s, loaded_layers)
	bootstrap_lazy()

	-- Calls the plugin method for each layer
	for _, layer in ipairs(loaded_layers) do
		if layer.plugins then
			layer.plugins(s)
		end
	end

	-- Setup lazy.nvim
	require("lazy").setup({
		spec = s.plugins,
		-- automatically check for plugin updates
		checker = { enabled = true },
		defaults = { lazy = false },
		performance = {
			rtp = { -- Disable unnecessary nvim features to speed up startup.

				paths = {
					setup.runtime_path, -- Add LYRD runtime path
				},
				disabled_plugins = {
					"tohtml",
					"gzip",
					"zipPlugin",
					"netrwPlugin",
					"tarPlugin",
				},
			},
		},
		-- Enable luarocks if installed.
		rocks = { enabled = vim.fn.executable("luarocks") == 1 },
		-- We don't use this, so create it in a disposable place.
		lockfile = vim.fn.stdpath("cache") .. "/lazy-lock.json",
	})
end

--- Calls the sequence of methods to initialize for each layer
---@param s LYRD.setup.Settings settings object
---@param loaded_layers  LYRD.setup.Module[]
local function load_settings(s, loaded_layers)
	for _, layer in ipairs(loaded_layers) do
		if layer.preparation ~= nil then
			layer.preparation(s)
		end
	end
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

---Calls the complete method for each layer
---@param s LYRD.setup.Settings settings object
---@param loaded_layers  LYRD.setup.Module[]
local function load_complete(s, loaded_layers)
	for _, layer in ipairs(loaded_layers) do
		if layer.complete ~= nil then
			layer.complete(s)
		end
	end
end

--- Calls the sequence of methods to initialize for each layer
--- @param s LYRD.setup.Settings settings object
function setup.load(s)
	s.plugins = {}
	---@type LYRD.setup.Module[]
	local loaded_layers = {}
	local vim_layers = {}
	for _, layer in ipairs(s.layers) do
		local L = require(layer)
		table.insert(loaded_layers, L)
		table.insert(vim_layers, L.name)
	end
	-- Updates LYRD_Settings in vim global
	local g_var = vim.g.LYRD_Settings
	g_var.Loaded_layers = vim_layers
	vim.g.LYRD_Settings = g_var

	-- Process each layer
	load_plugins(s, loaded_layers)
	load_settings(s, loaded_layers)
	load_complete(s, loaded_layers)
end

-- Enables a plugin with its name and options
function setup.plugin(s, plugin_list)
	for _, p in ipairs(plugin_list) do
		table.insert(s.plugins, p)
	end
end

return setup
