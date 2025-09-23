local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")

local L = {
	name = "Database",
	default_dialect = "ansi",
}

function L.plugins()
	setup.plugin({
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
	})
end

function L.preparation()
	-- Configures the null language server
	local null_ls = require("null-ls")
	lsp.mason_ensure({
		"sqlfluff",
		"sql-formatter",
		"sqls",
	})
	lsp.null_ls_register_sources({
		null_ls.builtins.diagnostics.sqlfluff.with({
			extra_args = { "--dialect", L.default_dialect }, -- change to your dialect
		}),
		null_ls.builtins.formatting.sqlfluff.with({
			extra_args = { "--dialect", L.default_dialect }, -- change to your dialect
		}),
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"sql",
	})
end

function L.settings()
	commands.implement("*", {
		{ cmd.LYRDDatabaseUI, ":DbCliSidebarToggle" },
		{ cmd.LYRDDatabaseOutput, ":DbCliOutputToggle" },
	})
	commands.implement("csv", {
		{ cmd.LYRDToggleBufferDecorations, ":CsvViewToggle" },
	})
	commands.implement("sql", {
		{ cmd.LYRDCodeRun, ":DbCliRunBuffer" },
		{ cmd.LYRDCodeRunSelection, ":DbCliRunAtCursor" },
		{ cmd.LYRDCodeQuerySelection, ":DbCliRunAtCursorCsv" },
	})
	commands.implement({ "sql", "db-cli-sidebar" }, {
		{ cmd.LYRDCodeSelectEnvironment, ":DbCliSelectConnection" },
		{ cmd.LYRDCodeSecrets, ":DbCliEditConnection" },
	})
end

function L.complete()
	vim.lsp.enable("sqls")
end

return L
