local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Rust Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.preparation(_)
	lsp.mason_ensure({
		"rust-analyzer",
	})
end

function L.settings(_) end

function L.complete(_)
	lsp.enable("rust_analyzer", {
		-- standalone file support
		-- setting it to false may improve startup time
		standalone = true,
	})
end

return L
