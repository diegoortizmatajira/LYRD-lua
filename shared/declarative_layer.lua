--- @class LYRD.setup.DeclarativeFormat
--- @field target_filetype string|string[] List of filetypes for which to apply the formatting configuration.
--- @field use_lsp nil|boolean Whether to use the LSP formatting capabilities for the specified filetypes. If false, the specified formatter(s) will be used instead.
--- @field format_settings nil|table List of formatters to be applied for the specified filetypes.
--- @field lsp_name nil|string The name of the LSP server to use for formatting, if use_lsp is true.
---
--- @class LYRD.setup.DeclarativeLSPConfig
--- @field [1] string The name of the LSP server for which to apply the configuration.
--- @field config function|table The configuration to apply for the specified LSP server.

--- @class LYRD.setup.DeclarativeLayer: LYRD.setup.Module Allows to create a layer module with a declarative style, by just specifying the required plugins, mason packages, treesitter parsers and enabled LSP servers. The methods of the module will be implemented with default implementations that take care of these requirements.
--- @field required_plugins nil|LazySpec[]
--- @field required_mason_packages nil|string[]  List of mason packages required by this module.
--- @field required_treesitter_parsers nil|string[]  List of treesitter parsers required by this module.
--- @field required_enabled_lsp_servers nil|(string|LYRD.setup.DeclarativeLSPConfig)[]  List of LSP servers that must be enabled for this module to load.
--- @field required_executables nil|string[]  List of executables that must be available in the system for this module to load.
--- @field required_formatters nil|table<string,function|table> List of formatters to be registered for this module, with the filetype as key and the formatter configuration as value. The formatter configuration can be either a function that returns the configuration or a table with the configuration directly.
--- @field required_formatter_per_filetype nil|LYRD.setup.DeclarativeFormat[]  List of formatting configurations to apply for this module.
--- @field required_test_adapters  nil|(string|any|function)[] List of test adapters to be registered for this module. It can be a module name to require, a function that returns the adapter configuration or the adapter configuration directly.
--- @field required_null_ls_sources nil|(string|any|function)[] List of null-ls sources to be registered for this module. It can be a list of module names to require.
--- @field required_filetype_definitions nil|vim.filetype.add.filetypes List of filetype definitions to be registered for this module, with the filetype as key and a list of glob patterns as value.

local DeclarativeLayer = {}

--- @param proto LYRD.setup.DeclarativeLayer The layer module for which to provide the standard implementation.
local function apply_plugins(proto)
	local original_plugins = proto.plugins
	return function()
		if proto.required_plugins then
			local setup = require("LYRD.setup")
			setup.plugin(proto.required_plugins)
		end
		if original_plugins then
			original_plugins()
		end
	end
end

--- @param proto LYRD.setup.DeclarativeLayer The layer module for which to provide the standard implementation.
local function apply_preparation(proto)
	local original_preparation = proto.preparation
	return function()
		local lsp = require("LYRD.layers.lsp")
		-- Ensure required mason packages to be installed
		if proto.required_mason_packages then
			lsp.mason_ensure(proto.required_mason_packages)
		end
		-- Ensure required Tree-sitter parsers to be installed
		if proto.required_treesitter_parsers then
			local ts = require("LYRD.layers.treesitter")
			ts.ensureParser(proto.required_treesitter_parsers or {})
		end
		-- Customize required formatters
		if proto.required_formatters then
			for key, value in pairs(proto.required_formatters) do
				lsp.customize_formatter(key, value)
			end
		end
		-- Apply required formatter per filetype configurations
		if proto.required_formatter_per_filetype then
			vim.tbl_map(function(format_config)
				if format_config.use_lsp and format_config.lsp_name then
					lsp.format_with_lsp(format_config.target_filetype, format_config.lsp_name)
				elseif format_config.format_settings then
					lsp.format_with_conform(format_config.target_filetype, format_config.format_settings)
				else
					vim.notify(
						string.format(
							"Invalid formatter configuration for filetype(s) %s in layer %s. Skipping.",
							vim.inspect(format_config.target_filetype),
							proto.name
						),
						vim.log.levels.WARN
					)
				end
			end, proto.required_formatter_per_filetype or {})
		end
		if proto.required_null_ls_sources then
			vim.tbl_map(function(source)
				local actual_source = source
				if type(source) == "function" then
					actual_source = source()
				elseif type(source) == "string" then
					actual_source = require(source)
				end
				lsp.null_ls_register_sources({ actual_source })
			end, proto.required_null_ls_sources or {})
		end
		-- Register required test adapters
		if proto.required_test_adapters then
			local test = require("LYRD.layers.test")
			vim.tbl_map(function(adapter)
				-- If the adapter is a function, call it to get the actual adapter configuration
				local actual_adapter = adapter
				if type(adapter) == "function" then
					actual_adapter = adapter()
				elseif type(adapter) == "string" then
					-- If the adapter is a string, assume it's the name of a module to require
					actual_adapter = require(adapter)
				end
				test.configure_adapter(actual_adapter)
			end, proto.required_test_adapters or {})
		end
		if original_preparation then
			original_preparation()
		end
	end
end

local function apply_settings(proto)
	local original_settings = proto.settings
	return function()
		if proto.required_filetype_definitions then
			vim.filetype.add(proto.required_filetype_definitions)
		end
		if original_settings then
			original_settings()
		end
	end
end

--- @param proto LYRD.setup.DeclarativeLayer The layer module for which to provide the standard implementation.
local function apply_complete(proto)
	local original_complete = proto.complete
	return function()
		if original_complete then
			original_complete()
		end
		if proto.required_enabled_lsp_servers then
			-- Enable required LSP servers
			vim.tbl_map(function(server)
				if type(server) == "table" and server[1] and server.config then
					if type(server.config) == "function" then
						server.config = server.config()
					end
					-- If the server is a table with the server name and configuration, apply the configuration
					vim.lsp.config(server[1], server.config)
					vim.lsp.enable(server[1])
				else
					-- Otherwise, assume it's just the server name and enable it with default configuration
					vim.lsp.enable(server)
				end
			end, proto.required_enabled_lsp_servers or {})
		end
	end
end

--- @param proto LYRD.setup.DeclarativeLayer The layer module for which to provide the standard implementation.
local function apply_healthcheck(proto)
	local original_healthcheck = proto.healthcheck
	return function()
		if original_healthcheck or proto.required_executables then
			vim.health.start(proto.name)
		end
		if original_healthcheck then
			original_healthcheck()
		end
		if proto.required_executables then
			local health = require("LYRD.health")
			vim.tbl_map(function(executable)
				health.check_executable(executable)
			end, proto.required_executables or {})
		end
	end
end

--- Standardizes a prototype table into a standard layer module. This is useful
--- to create a layer module with a declarative style, by just specifying the
--- required plugins, mason packages, Tree-sitter parsers and enabled LSP
--- servers. The methods of the module will be implemented with default
--- implementations that take care of these requirements.
--- @param proto table|LYRD.setup.DeclarativeLayer A prototype table that contains the fields of the layer to be created.
--- @return LYRD.setup.Module A standardized layer module based on the provided prototype.
function DeclarativeLayer.apply(proto)
	proto.plugins = apply_plugins(proto)
	proto.preparation = apply_preparation(proto)
	proto.settings = apply_settings(proto)
	proto.complete = apply_complete(proto)
	proto.healthcheck = apply_healthcheck(proto)
	return proto
end

function DeclarativeLayer.source_with_opts(name, opts)
	return function()
		return require(name).with(opts or {})
	end
end

return DeclarativeLayer
