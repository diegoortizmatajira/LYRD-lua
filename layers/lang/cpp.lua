local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = {
	name = "C and C++",
	filetypes = { "c", "cpp", "h" },
}
local function setup_dap()
	local dap = require("dap")
	dap.adapters.codelldb = require("LYRD.shared.dap.codelldb")
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
	dap.configurations.cpp = debug_configuration
	dap.configurations.c = debug_configuration
	dap.configurations.h = debug_configuration
end

function L.plugins()
	setup.plugin({
		{
			"alfaix/neotest-gtest",
			ft = L.filetypes,
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"clangd",
		"codelldb",
	})
	lsp.format_with_conform(L.filetypes, {
		"clang-format",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"c",
		"cpp",
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-gtest").setup({}))
end

function L.settings()
	setup_dap()
	commands.implement("*", {
		-- { cmd.LYRDXXXX, ":XXXXX" },
	})
end

function L.keybindings() end

function L.complete()
	vim.lsp.enable("clangd")
end
return L
