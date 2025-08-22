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
			"nvimtools/none-ls-extras.nvim",
		},
		{
			"orjangj/neotest-ctest",
			ft = L.filetypes,
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"clangd",
		"codelldb",
		"clang-format",
		"cpplint",
		"cmakelint",
		"cmake-language-server",
	})
	lsp.customize_formatter("clang-format", require("LYRD.shared.conform.clang-format"))
	lsp.format_with_conform(L.filetypes, { "clang-format" })
	lsp.null_ls_register_sources({
		require("none-ls.diagnostics.cpplint"),
		require("null-ls.builtins.diagnostics.cmake_lint"),
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"cmake",
		"c",
		"cpp",
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-ctest").setup({}))
end

function L.settings()
	local debugger = require("LYRD.shared.dap.codelldb")
	debugger.setup(L.filetypes)
	-- local cmd = require("LYRD.layers.lyrd-commands").cmd
	-- commands.implement("*", {
	-- 	{ cmd.LYRDCodeAlternateFile, ":ClangdSwitchSourceHeader" },
	-- })
end

function L.keybindings() end

function L.complete()
	vim.lsp.enable({
		"clangd",
		"cmake",
	})
end
return L
