local utils = require("LYRD.utils")

---@class LYRD.setup.Settings
---@field layers string[] contains the list of layers provided in init script
---@field loaded_layers? LYRD.setup.Module[] contains the list of names of the loaded layers
---@field plugins? LazySpec[] contains the list of plugins loaded
---@field commands? table<string, table<string, string|function>> contains the list of implemented commands

---@class LYRD.setup.Module
---@field name string
---@field plugins? nil|fun():nil
---@field preparation? nil|fun():nil
---@field settings? nil|fun():nil
---@field keybindings? nil|fun():nil
---@field complete? nil|fun():nil
---@field healthcheck? nil|fun():nil

local setup = {
	configs_path = utils.get_lyrd_path() .. "/configs",
	runtime_path = utils.get_lyrd_path() .. "/runtime",
	---@type LYRD.setup.Settings
	config = {
		commands = {},
		plugins = {},
		loaded_layers = {},
		layers = {},
	},
}

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
local function load_plugins()
	bootstrap_lazy()

	-- Calls the plugin method for each layer
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.plugins then
			layer.plugins()
		end
	end

	-- Setup lazy.nvim
	require("lazy").setup({
		spec = setup.config.plugins,
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
--- @param s LYRD.setup.Settings settings object
function setup.load(s)
	setup.config = vim.tbl_deep_extend("force", setup.config, s) or setup.config
	---@type LYRD.setup.Module[]
	for _, layer in ipairs(setup.config.layers) do
		local L = require(layer)
		table.insert(setup.config.loaded_layers, L)
	end

	-- Process each layer
	load_plugins()
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.preparation ~= nil then
			layer.preparation()
		end
	end
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.settings ~= nil then
			layer.settings()
		end
	end
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.keybindings ~= nil then
			layer.keybindings()
		end
	end
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.complete ~= nil then
			layer.complete()
		end
	end
end

-- Enables a plugin with its name and options
--- @param plugin_list LazySpec[]
function setup.plugin(plugin_list)
	for _, p in ipairs(plugin_list) do
		table.insert(setup.config.plugins, p)
	end
end

return setup
