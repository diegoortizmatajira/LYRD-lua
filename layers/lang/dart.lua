local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Dart",
	required_plugins = {
		{
			"nvim-flutter/flutter-tools.nvim",
			lazy = false,
			dependencies = {
				"nvim-lua/plenary.nvim",
				"stevearc/dressing.nvim", -- optional for vim.ui.select
			},
			opts = {
				debugger = {
					enabled = true,
				},
			},
		},
	},
	required_treesitter_parsers = {
		"dart",
	},
	required_enabled_lsp_servers = {
		-- dartls is started by the flutter-tools.nvim plugin, so we don't need to start it manually.
	},
	required_executables = { "dart", "flutter" },
}

function L.preparation()
	local debugger = require("LYRD.shared.dap.dart")
	debugger.setup({ "dart", "flutter" })
end

function L.settings() end

return declarative_layer.apply(L)
