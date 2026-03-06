--- @class LYRD.setup.ConcreteModule: LYRD.setup.Module
--- @field required_plugins LazySpec[]
--- @field required_mason_packages nil|string[]  List of mason packages required by this module.
--- @field required_treesitter_parsers nil|string[]  List of treesitter parsers required by this module.
--- @field required_enabled_lsp_servers nil|string[]  List of LSP servers that must be enabled for this module to load.
local ConcreteModule = {}
ConcreteModule.__index = ConcreteModule

--- Constructor
--- @generic T: LYRD.setup.ConcreteModule
--- @param proto T A prototype table that contains the fields of the module to be created.
--- @return T & LYRD.setup.ConcreteModule An instance of the module created from the prototype.
function ConcreteModule:new(proto)
	local o = setmetatable(proto, self)
	return o
end

function ConcreteModule:plugins()
	if self.required_plugins then
		local setup = require("LYRD.setup")
		setup.plugin(self.required_plugins)
	end
end

function ConcreteModule:preparation()
	-- Ensure required mason packages to be installed
	if self.required_mason_packages then
		local lsp = require("LYRD.layers.lsp")
		lsp.mason_ensure(self.required_mason_packages)
	end
	-- Ensure required TreeSitter parsers to be installed
	if self.required_treesitter_parsers then
		local ts = require("LYRD.layers.treesitter")
		ts.ensureParser(self.required_treesitter_parsers or {})
	end
end

function ConcreteModule:settings()
	-- Default empty implementation
end

function ConcreteModule:keybindings()
	-- Default empty implementation
end

function ConcreteModule:complete()
	-- Enable required LSP servers
	vim.tbl_map(function(server)
		vim.lsp.enable(server)
	end, self.required_enabled_lsp_servers or {})
end

function ConcreteModule:healthcheck()
	-- Default empty implementation
end

return ConcreteModule
