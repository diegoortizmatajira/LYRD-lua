local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Database" }

function L.plugins()
	setup.plugin({
		{
			"diegoortizmatajira/db-cli-adapter.nvim",
			dir = "/home/diegoortizmatajira/Development/contrib/db-cli-adapter.nvim",
			opts = {},
		},
	})
end

function L.preparation() end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDDatabaseUI, ":DbCliSidebarToggle" },
	})
	commands.implement("sql", {
		{ cmd.LYRDCodeRun, ":DbCliRunBuffer" },
		{ cmd.LYRDCodeRunSelection, ":DbCliRunAtCursor" },
	})
	commands.implement({ "sql", "db-cli-sidebar" }, {
		{ cmd.LYRDCodeSelectEnvironment, ":DbCliSelectConnection" },
	})
end

return L
