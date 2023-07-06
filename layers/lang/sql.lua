local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local format = require("LYRD.layers.format")

local L = { name = "SQL Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(_)
	local formatters = {
		{
			exe = "sqlfmt",
			args = { "-" },
			stdin = 1,
		},
	}
	format.add_formatters("sql", formatters)
	lsp.mason_ensure({
		"sqlfmt",
	})
end

function L.complete(_)
	lsp.enable("sqlls")
end

return L
