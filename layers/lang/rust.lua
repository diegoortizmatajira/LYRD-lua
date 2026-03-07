local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Rust Language",
	required_plugins = {
		{
			"mrcjkb/rustaceanvim",
			version = "^6", -- Recommended
			lazy = false, -- This plugin is already lazy
		},
		{
			"saecki/crates.nvim",
			event = { "BufRead Cargo.toml" },
			opts = {
				completion = {
					crates = {
						enabled = true,
					},
				},
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
			},
		},
	},
	required_mason_packages = {
		"rust-analyzer",
		"bacon",
		"bacon-ls",
	},
	required_treesitter_parsers = {
		"rust",
		"ron",
	},
	required_enabled_lsp_servers = {
		"bacon_ls",
	},
	required_test_adapters = {
		"rustaceanvim.neotest",
	},
}

function L.settings()
	local debugger = require("LYRD.shared.dap.codelldb")
	debugger.setup({ "rust" })
end

return declarative_layer.apply(L)
