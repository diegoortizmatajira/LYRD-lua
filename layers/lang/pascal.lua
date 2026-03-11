local icons = require("LYRD.layers.icons")
local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Pascal",
	required_plugins = {},
	required_mason_packages = {},
	required_treesitter_parsers = {},
	required_enabled_lsp_servers = {},
	required_executables = {
	    "pfc"
	},
	required_formatters = {},
	required_formatter_per_filetype = {},
	required_test_adapters = {},
}

function L.plugins()
	local setup = require("LYRD.setup")
	setup.plugin({})
end

function L.preparation() end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	commands.implement("*", {
		-- { cmd.LYRDXXXX, ":XXXXX" },
	})
end

function L.keybindings() end

function L.complete() end

return declarative_layer.apply(L)
