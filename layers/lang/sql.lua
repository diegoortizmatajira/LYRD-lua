local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "SQL Language" }

function L.plugins(s)
	setup.plugin({})
end

function L.preparation(_)
	-- Configures the null language server
	local null_ls = require("null-ls")
	local default_dialect = "tsql"
	lsp.mason_ensure({
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

function L.settings(_) end

function L.complete(_)
	lsp.enable("sqlls")
end

return L
