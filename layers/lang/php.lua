local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Php",
	required_plugins = {},
	required_mason_packages = {
		"intelephense",
		"laravel-ls",
		"php-cs-fixer",
	},
	required_treesitter_parsers = {
		"php",
	},
	required_enabled_lsp_servers = {
		"intelephense",
		"laravel_ls",
	},
	required_executables = {},
	required_formatters = {},
	required_formatter_per_filetype = {
		{
			target_filetype = "php",
			format_settings = { "php-cs-fixer" },
		},
	},
	required_test_adapters = {},
	required_null_ls_sources = {},
	required_filetype_definitions = {},
}

function L.plugins()
	local setup = require("LYRD.shared.setup")
	setup.plugin({})
end

function L.preparation() end

function L.keybindings() end

function L.complete() end

return declarative_layer.apply(L)
