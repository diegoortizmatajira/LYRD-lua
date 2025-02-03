local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Rust Language" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
	lsp.mason_ensure({
		"rust-analyzer",
	})
end

function L.settings() end

function L.complete()
	lsp.enable("rust_analyzer", {
		-- standalone file support
		-- setting it to false may improve startup time
		standalone = true,
	})
end

return L
