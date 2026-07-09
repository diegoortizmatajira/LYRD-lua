local declarative_layer = require("LYRD.shared.declarative_layer")
local filetypes = { "c", "cpp", "h" }

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "C and C++ Languages",
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
	},
	required_treesitter_parsers = {
		"c",
		"cpp",
	},
	required_enabled_lsp_servers = {
		"clangd",
	},
	required_formatters = {
		["clang-format"] = require("LYRD.shared.conform.clang-format"),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = filetypes,
			format_settings = { "clang-format" },
		},
	},
	required_test_adapters = {
		function()
			return require("neotest-ctest").setup({})
		end,
	},
	required_null_ls_sources = {
		"none-ls.diagnostics.cpplint",
	},
}

function L.settings()
	local debugger = require("LYRD.shared.dap.codelldb")
	debugger.setup(filetypes)
end

return declarative_layer.apply(L)
