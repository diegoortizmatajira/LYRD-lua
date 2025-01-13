local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Database" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"kristijanhusak/vim-dadbod-ui",
			dependencies = {
				{
					"tpope/vim-dadbod",
					lazy = true,
				},
				{
					"kristijanhusak/vim-dadbod-completion",
					ft = { "sql", "mysql", "plsql" },
					lazy = true,
				}, -- Optional
			},
			cmd = {
				"DBUI",
				"DBUIToggle",
				"DBUIAddConnection",
				"DBUIFindBuffer",
			},
			init = function()
				vim.g.db_ui_use_nerd_fonts = 1
				vim.g.db_ui_execute_on_save = 0
				vim.g.db_ui_table_helpers = {
					postgresql = {
						["Preview data"] = [[select * from "{table}" limit 10]],
						Count = [[select count(*) from "{table}"]],
					},
					sqlite = {
						["Preview data"] = [[select * from "{table}" limit 10]],
						Count = [[select count(*) from "{table}"]],
					},
				}
			end,
		},
		{ "muniftanjim/nui.nvim" },
	})
end

function L.settings(s)
	commands.implement(s, "*", {
		{ cmd.LYRDDatabaseUI, ":DBUIToggle" },
	})
	commands.implement(s, "sql", {
		{ cmd.LYRDCodeRun, ":%DB" },
		{ cmd.LYRDCodeRunSelection, ":'<,'>DB" },
	})
end

return L
