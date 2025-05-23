local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Database" }

function L.plugins()
	setup.plugin({
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

		{
			"kristijanhusak/vim-dadbod-completion",
			ft = { "sql", "mysql", "plsql" },
			lazy = true,
		},
		{ "muniftanjim/nui.nvim" },
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDDatabaseUI, ":DBUIToggle" },
	})
	commands.implement("sql", {
		{ cmd.LYRDCodeRun, ":%DB" },
		{ cmd.LYRDCodeRunSelection, ":'<,'>normal <Plug>(DBUI_ExecuteQuery)" },
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "sql", "mysql", "plsql" },
		callback = function()
			require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
		end,
	})
end

return L
