--- @class LYRD.setup.DeclarativeLayer: LYRD.setup.Module Allows to create a layer module with a declarative style, by just specifying the required plugins, mason packages, treesitter parsers and enabled LSP servers. The methods of the module will be implemented with default implementations that take care of these requirements.
--- @field required_plugins nil|LazySpec[]
--- @field required_mason_packages nil|string[]  List of mason packages required by this module.
--- @field required_treesitter_parsers nil|string[]  List of treesitter parsers required by this module.
--- @field required_enabled_lsp_servers nil|string[]  List of LSP servers that must be enabled for this module to load.
--- @field required_executables nil|string[]  List of executables that must be available in the system for this module to load.

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
		-- Ensure required mason packages to be installed
		if proto.required_mason_packages then
			local lsp = require("LYRD.layers.lsp")
			lsp.mason_ensure(proto.required_mason_packages)
		end
		-- Ensure required Tree-sitter parsers to be installed
		if proto.required_treesitter_parsers then
			local ts = require("LYRD.layers.treesitter")
			ts.ensureParser(proto.required_treesitter_parsers or {})
		end
		if original_preparation then
			original_preparation()
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
				vim.lsp.enable(server)
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
	proto.complete = apply_complete(proto)
	proto.healthcheck = apply_healthcheck(proto)
	return proto
end

return DeclarativeLayer
