local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Rust Language" }

function L.plugins(s)
	setup.plugin(s, {})
end

function L.settings(_)
	lsp.mason_ensure({
		"rust-analyzer",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.rustfmt,
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
