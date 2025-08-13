local setup = require("LYRD.setup")
local lsp = require("LYRD.layers.lsp")

local L = { name = "Rust Language" }

local function setup_dap()
	local dap = require("dap")
	dap.adapters.codelldb = require("LYRD.configs.codelldb")
	local debug_configuration = {
		{
			name = "runit",
			type = "codelldb",
			request = "launch",

			program = function()
				return vim.fn.input("", vim.fn.getcwd(), "file")
			end,

			args = { "--log_level=all" },
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			terminal = "integrated",

			pid = function()
				local handle = io.popen("pgrep hw$")
				local result = handle:read()
				handle:close()
				return result
			end,
		},
	}
	dap.configurations.rust = debug_configuration
end
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
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"rust",
	})
end

function L.settings()
	setup_dap()
end

function L.complete() end

return L
