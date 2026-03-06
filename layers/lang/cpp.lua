local concrete_module = require("LYRD.shared.concrete_module")

local filetypes = { "c", "cpp", "h" }

local L = concrete_module:new({
	name = "C and C++",
	required_plugins = {
		{
			"nvimtools/none-ls-extras.nvim",
		},
		{
			"orjangj/neotest-ctest",
			ft = filetypes,
		},
	},
	required_mason_packages = {
		"clangd",
		"codelldb",
		"clang-format",
		"cpplint",
		"cmakelint",
		"cmake-language-server",
	},
	required_treesitter_parsers = {
		"cmake",
		"c",
		"cpp",
	},
	required_enabled_lsp_servers = {
		"clangd",
		"cmake",
	},
})

function L:preparation()
	concrete_module.preparation(self)

	local lsp = require("LYRD.layers.lsp")
	lsp.customize_formatter("clang-format", require("LYRD.shared.conform.clang-format"))
	lsp.format_with_conform(filetypes, { "clang-format" })
	lsp.null_ls_register_sources({
		require("none-ls.diagnostics.cpplint"),
		require("null-ls.builtins.diagnostics.cmake_lint"),
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-ctest").setup({}))
end

function L:settings()
	concrete_module.settings(self)
	local debugger = require("LYRD.shared.dap.codelldb")
	debugger.setup(filetypes)
end

return L
