local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")
local format = require("LYRD.layers.format")

local L = { name = "Rust Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(_)
	format.add_formatters("rust", { require("formatter.filetypes.rust").rustfmt })
	lsp.mason_ensure({
		"rust-analyzer",
		"rustfmt",
	})
end

function L.complete(_)
	lsp.enable("rust_analyzer", {
		-- standalone file support
		-- setting it to false may improve startup time
		standalone = true,
	})
end

return L
