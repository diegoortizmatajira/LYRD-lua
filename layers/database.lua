local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Database" }

function L.plugins(s)
	setup.plugin(s, {
		"muniftanjim/nui.nvim",
		{
			"kndndrj/nvim-dbee",
			dependencies = {
				"muniftanjim/nui.nvim",
			},
			build = function()
				-- Install tries to automatically detect the install method.
				-- if it fails, try calling it with one of these parameters:
				--    "curl", "wget", "bitsadmin", "go"
				require("dbee").install()
			end,
			opts = {},
		},
	})
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDDatabaseUI, ":Dbee" },
	})
end

return L
