local declarative_layer = require("LYRD.shared.declarative_layer")
local filetype = require("vim.filetype")

local default_dialect = "ansi"

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "SQL language",
	required_plugins = {
		{
			"diegoortizmatajira/db-cli-adapter.nvim",
			-- dir = "/home/diegoortizmatajira/Development/contrib/db-cli-adapter.nvim",
			--- @class DbCliAdapter.Config
			opts = {
				output = {
					csv = {
						after_query_callback = function(bufnr)
							--- Enable CsvView for the output buffer if the output is in CSV format'
							vim.api.nvim_buf_call(bufnr, function()
								vim.cmd("CsvViewEnable")
							end)
						end,
					},
				},
			},
			config = function(_, opts)
				-- Use the default connection change handler from the db-cli-adapter configuration
				opts.connection_change_handler = require("db-cli-adapter.config").sqls_connection_change_handler
				require("db-cli-adapter").setup(opts)
			end,
		},
		{
			"hat0uma/csvview.nvim",
			---@module "csvview"
			---@type CsvView.Options
			opts = {
				parser = { comments = { "#", "//" } },
				keymaps = {
					-- Text objects for selecting fields
					textobject_field_inner = { "if", mode = { "o", "x" } },
					textobject_field_outer = { "af", mode = { "o", "x" } },
					-- Excel-like navigation:
					-- Use <Tab> and <S-Tab> to move horizontally between fields.
					-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
					-- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
					jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
					jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
					jump_next_row = { "<Enter>", mode = { "n", "v" } },
					jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
				},
			},
			cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		},
	},
	required_mason_packages = {
		"sqlfluff",
		"sql-formatter",
		"sqls",
	},
	required_treesitter_parsers = {
		"sql",
	},
	required_enabled_lsp_servers = {
		"sqls",
	},
	required_null_ls_sources = {
		declarative_layer.source_with_opts(
			"null-ls.builtins.diagnostics.sqlfluff",
			{ extra_args = { "--dialect", default_dialect } }
		),
		declarative_layer.source_with_opts(
			"null-ls.builtins.formatting.sqlfluff",
			{ extra_args = { "--dialect", default_dialect } }
		),
	},
	sql_command_ts_query = [[
[
    (program)
    (statement)
    (subquery)
] @sql-command
	]],
}

--- Executes a SQL command at the cursor position.
--- Uses a Tree-sitter query to select the SQL command node, and allows running it with a database CLI adapter.
---
--- @param csv? boolean If true, outputs the result in CSV format.
function L.run_at_cursor(csv)
	require("LYRD.shared.run_code").run_selection({
		title = "Confirm SQL instruction to run",
		treesitter_selector = {
			query_string = L.sql_command_ts_query,
			lang = "sql",
			node_capture_name = "sql-command",
			recursive_search = true,
		},
		generator = function(_, command, i)
			return {
				{
					name = string.format("Run candidate command %d", i),
					preview = command,
					filetype = "sql",
					runner = function()
						local db_cli_adapter = require("db-cli-adapter")
						db_cli_adapter.run_with_buffer_connection(command, csv)
					end,
				},
			}
		end,
		display_one_option_list = true,
	})
end

function L.settings()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.register_decoration_togglers("sql", { ":CsvViewToggle" })

	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	commands.implement("*", {
		{ cmd.LYRDDatabaseUI, ":DbCliSidebarToggle" },
		{ cmd.LYRDDatabaseOutput, ":DbCliOutputToggle" },
	})
	commands.implement("sql", {
		{ cmd.LYRDCodeRun, ":DbCliRunBuffer" },
		{
			cmd.LYRDCodeRunSelection,
			function()
				L.run_at_cursor()
			end,
		},
		{
			cmd.LYRDCodeQuerySelection,
			function()
				L.run_at_cursor(true)
			end,
		},
	})
	commands.implement({ "sql", "db-cli-sidebar" }, {
		{ cmd.LYRDCodeSelectEnvironment, ":DbCliSelectConnection" },
		{ cmd.LYRDCodeSecrets, ":DbCliEditConnection" },
	})
end
return declarative_layer.apply(L)
