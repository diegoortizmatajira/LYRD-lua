local utils = require("LYRD.utils")

--- @class LYRD.setup.LocalConfig
--- @field skip_layers? string[] List of layers to skip loading
---
---@class LYRD.setup.Settings: LYRD.setup.LocalConfig
---@field layers string[] contains the list of layers provided in init script
---@field loaded_layers? LYRD.setup.Module[] contains the list of names of the loaded layers
---@field plugins? LazySpec[] contains the list of plugins loaded
---@field commands? table<string, table<string, string|function>> contains the list of implemented commands

---@class LYRD.setup.Module
---@field name string Name of the layer
---@field condition? nil|boolean Condition to check if the layer should be loaded
---@field vscode_compatible? nil|boolean If true, the layer is compatible with vscode
---@field plugins? nil|fun() Function to load the plugins for the layer
---@field preparation? nil|fun() Function to prepare the layer, called before settings
---@field settings? nil|fun() Function to set the settings for the layer, called after preparation
---@field keybindings? nil|fun() Function to set the keybindings for the layer, called after settings
---@field complete? nil|fun() Function to complete the layer, called after keybindings
---@field healthcheck? nil|fun() Function to check the health of the layer
---@field run_once_per_filetype? nil|table<string|string[], fun()> Allows to define actions to run once per filetype

local setup = {
	configs_path = utils.get_lyrd_path("configs"),
	runtime_path = utils.get_lyrd_path("runtime"),
	data_path = utils.get_lyrd_data_path(),
	local_config_path = utils.get_lyrd_data_path("lyrd-local.lua"),
	---@type LYRD.setup.Settings
	config = {
		commands = {},
		plugins = {},
		loaded_layers = {},
		layers = {},
	},
}

vim.fn.mkdir(setup.data_path, "p")

-- Is a dictionary to control filetype commands to run only once
local run_once_per_file_type_execution = {}

--- Bootstraps the Lazy.nvim plugin manager.
---
--- This function ensures that the Lazy.nvim plugin manager is installed and
--- available for use. If Lazy.nvim is not already installed, it will be cloned
--- from its Git repository. The function also updates the runtime path to include
--- the Lazy.nvim directory.
---
--- If the cloning process fails, an error message is displayed, and the program
--- exits. This ensures that Lazy.nvim is set up correctly before being used to
--- manage plugins.
local function bootstrap_lazy()
	-- Bootstrap lazy.nvim
	local lazypath = utils.join_paths(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
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
			vim.cmd("cquit 1")
		end
	end
	vim.opt.rtp:prepend(lazypath)
end

--- Initializes and configures plugins for the Neovim environment.
---
--- This function first ensures that the Lazy.nvim plugin manager is bootstrapped
--- and available. It then iterates through the loaded layers in the configuration,
--- invoking the `plugins` method for each layer to load its specific plugins.
---
--- After setting up the layers' plugins, the function configures the Lazy.nvim
--- plugin manager with various settings, including plugin specifications, update
--- checking, performance optimizations, and lockfile management.
local function load_plugins()
	bootstrap_lazy()

	-- Calls the plugin method for each layer
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.plugins then
			local ok, result = pcall(layer.plugins)
			if not ok then
				vim.notify(
					"Error in layer '" .. layer.name .. "' during stage 'plugins': " .. result,
					vim.log.levels.ERROR
				)
			end
		end
	end

	-- Setup lazy.nvim
	require("lazy").setup({
		spec = setup.config.plugins,
		-- automatically check for plugin updates
		checker = { enabled = true },
		defaults = { lazy = false },
		concurrency = 50,
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
		lockfile = utils.join_paths(vim.fn.stdpath("cache"), "lazy-lock.json"),
	})
end

--- Loads a layer module if it meets the conditions to be loaded.
--- This function checks if the layer is in the skip list, evaluates its
--- condition, and verifies compatibility with VSCode if applicable.
---
--- @param layer_module string The module name of the layer to load.
--- @return LYRD.setup.Module|nil The loaded layer module or nil if it should not be loaded
local function load_if_should_be_loaded(layer_module)
	--- Check if the layer is in the skip list (doesn't even load it)
	if vim.list_contains(setup.config.skip_layers or {}, layer_module) then
		return nil
	end
	--- Load the layer module
	local ok, layer = pcall(require, layer_module)
	if not ok then
		vim.notify("Failed to load layer '" .. layer_module .. "': " .. layer, vim.log.levels.ERROR)
		return nil
	end
	if type(layer) ~= "table" then
		vim.notify("Layer '" .. layer_module .. "' did not return a table", vim.log.levels.WARN)
		return nil
	end
	--- @type LYRD.setup.Module
	--- Check if the layer has a condition and if it is not met
	if layer.condition ~= nil and not layer.condition then
		return nil
	end
	--- Check if vscode is running and the layer is compatible with vscode
	if vim.g.vscode and not layer.vscode_compatible then
		return nil
	end
	return layer
end

--- Reads and merges local configuration settings.
local function read_local_config()
	-- If the local config file exists, load it and merge its settings
	-- into the main config
	if vim.uv.fs_stat(setup.local_config_path) then
		local ok, local_config = pcall(dofile, setup.local_config_path)
		if not ok then
			vim.notify("Error loading local config: " .. local_config, vim.log.levels.ERROR)
			return
		end
		if type(local_config) == "table" then
			if local_config.skip_layers then
				setup.config.skip_layers = local_config.skip_layers
			end
		end
	end
end

function setup.edit_local_config()
	utils.open_or_create_file(setup.local_config_path)
end

--- Loads and initializes the LYRD setup configuration.
---
--- This function accepts a setup table that defines the layers, plugins, and commands to be used.
--- It evaluates each layer to check its loading conditions and processes its stages in the
--- following order: `preparation`, `settings`, `keybindings`, and `complete`. For each layer,
--- the respective functions are called if they are defined.
---
--- Additionally, this function handles `run_once_per_filetype` commands for layers. These
--- commands are associated with specified filetypes and are ensured to execute only once
--- per filetype. Autocommands are created dynamically to manage these filetype-specific actions.
---
--- @param s LYRD.setup.Settings The setup configuration table containing layers, plugins, and commands.
function setup.load(s)
	setup.config = vim.tbl_deep_extend("force", setup.config, s)
	read_local_config()
	for _, layer in ipairs(setup.config.layers) do
		local loaded_layer = load_if_should_be_loaded(layer)
		if loaded_layer then
			table.insert(setup.config.loaded_layers, loaded_layer)
		end
	end

	-- Process each layer
	load_plugins()
	-- Define the stages to be called in order
	local stages = { "preparation", "settings", "keybindings", "complete" }
	for _, stage_function_name in ipairs(stages) do
		for _, layer in ipairs(setup.config.loaded_layers) do
			if layer[stage_function_name] ~= nil then
				local ok, result = pcall(layer[stage_function_name])
				if not ok then
					vim.notify(
						"Error in layer '" .. layer.name .. "' during stage '" .. stage_function_name .. "': " .. result,
						vim.log.levels.ERROR
					)
				end
			end
		end
	end
	-- Creates auto-commands for the run_once_per_filetype commands
	for _, layer in ipairs(setup.config.loaded_layers) do
		if layer.run_once_per_filetype ~= nil then
			for ft, command_callback in pairs(layer.run_once_per_filetype) do
				local key = layer.name .. ":" .. ft
				vim.api.nvim_create_autocmd("FileType", {
					pattern = ft,
					callback = function()
						if run_once_per_file_type_execution[key] then
							return
						end
						local cb_ok, cb_result = pcall(command_callback)
						if not cb_ok then
							vim.notify(
								"Error in layer '" .. layer.name .. "' run_once_per_filetype for '" .. ft .. "': " .. cb_result,
								vim.log.levels.ERROR
							)
						end
						run_once_per_file_type_execution[key] = true
					end,
				})
			end
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
