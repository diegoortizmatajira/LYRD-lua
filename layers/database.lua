local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local c = commands.command_shortcut

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
				-- Your DBUI configuration
				vim.g.db_ui_use_nerd_fonts = 1
			end,
		},
		{ "muniftanjim/nui.nvim" },
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
		{ cmd.LYRDDatabaseUI, ":DBUIToggle" },
	})
	commands.implement(s, "sql", {
		{ cmd.LYRDCodeRun, "%DB" },
		{ cmd.LYRDCodeRunSelection, "'<,'>DB" },
	})
end

return L
