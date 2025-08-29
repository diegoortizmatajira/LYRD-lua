local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

---@type LYRD.setup.Module
local L = { name = "Rust Language" }

function L.plugins()
	setup.plugin({
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
	})
end

function L.preparation()
	lsp.mason_ensure({
		"rust-analyzer",
		"bacon",
		"bacon-ls",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"rust",
		"ron",
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("rustaceanvim.neotest"))
end

function L.settings()
	local debugger = require("LYRD.shared.dap.codelldb")
	debugger.setup({ "rust" })
end

function L.complete()
	vim.lsp.enable({
		-- Rust analyzer is initiallized by rustaceanvim, enabling it here would cause duplicate LSP clients
		-- "rust-analyzer",
		"bacon_ls",
	})
end

return L
