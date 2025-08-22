local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = {
	name = "C and C++",
	filetypes = { "c", "cpp", "h" },
}

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
		"clang-format",
	})
	lsp.customize_formatter("clang-format", require("LYRD.shared.conform.clang-format"))
	lsp.format_with_conform(L.filetypes, { "clang-format" })
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"c",
		"cpp",
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-gtest").setup({}))
end

function L.settings()
	local debugger = require("LYRD.shared.dap.codelldb")
	debugger.setup(L.filetypes)
	commands.implement("*", {
		-- { cmd.LYRDXXXX, ":XXXXX" },
	})
end

function L.keybindings() end

function L.complete()
	vim.lsp.enable("clangd")
end
return L
