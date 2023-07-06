local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")
local format = require("LYRD.layers.format")

local L = { name = "SQL Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(s)
	commands.implement(s, "sql", {
		{
			cmd.LYRDBufferFormat,
			function()
				vim.lsp.buf.format({ async = true })
			end,
		},
	})

	-- Configures the null language server
	local null_ls = require("null-ls")
	local default_dialect = "tsql"
	lsp.mason_ensure({
		"sqlfmt",
		"sqlfluff",
	})
	lsp.null_ls_register_sources({
		null_ls.builtins.diagnostics.sqlfluff.with({
			extra_args = { "--dialect", default_dialect }, -- change to your dialect
		}),
		null_ls.builtins.formatting.sqlfluff.with({
			extra_args = { "--dialect", default_dialect }, -- change to your dialect
		}),
	})
end

function L.complete(_)
	lsp.enable("sqlls")
end

return L
