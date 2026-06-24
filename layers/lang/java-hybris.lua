local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")
local Command = commands.Command
local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Java - Hybris (SAP Commerce) support",
	required_plugins = {},
	required_mason_packages = {},
	required_treesitter_parsers = {},
	required_enabled_lsp_servers = {},
	required_executables = {},
	required_formatters = {},
	required_formatter_per_filetype = {},
	required_test_adapters = {},
	required_null_ls_sources = {},
	required_filetype_definitions = {},
	LYRDJavaHybrisLoadSolution = Command:new("Hybris: Load solution (Java)", nil, icons.folder.open),
}

function L.plugins()
	local setup = require("LYRD.shared.setup")
	setup.plugin({})
end

function L.preparation() end

function L.settings()
	commands.register({
		LYRDJavaHybrisLoadSolution = L.LYRDJavaHybrisLoadSolution,
	})
	commands.implement("*", {
		{ L.LYRDJavaHybrisLoadSolution, ":XXXXX" },
	})
end

function L.keybindings()
	local mappings = require("LYRD.layers.mappings")
	mappings.keys({
		{ "n", "<Space>cH", L.LYRDJavaHybrisLoadSolution },
	})
end

function L.complete() end

return declarative_layer.apply(L)
