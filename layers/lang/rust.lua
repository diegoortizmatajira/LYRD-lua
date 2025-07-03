local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Rust Language" }

function L.plugins()
	setup.plugin({
		{
			"mrcjkb/rustaceanvim",
			version = "^6", -- Recommended
			lazy = false, -- This plugin is already lazy
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"rust-analyzer",
	})
end

function L.settings() end

function L.complete() end

return L
