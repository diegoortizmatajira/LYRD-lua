local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Lua Language",
	required_plugins = {
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {},
			init = function()
				vim.g.lazydev_enabled = true
			end,
		},
		{ "Bilal2453/luvit-meta", lazy = true },
		{
			"nvim-neotest/neotest-plenary",
		},
	},
	required_mason_packages = {
		"lua-language-server",
		"luacheck",
		"luaformatter",
		"luau-lsp",
		"stylua",
		"selene",
	},
	required_treesitter_parsers = {
		"lua",
		"luap",
		"luau",
		"luadoc",
	},
	required_enabled_lsp_servers = {
		"lua_ls",
	},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.selene",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = { "lua", "luau" },
			format_settings = { "stylua" },
		},
	},
	required_test_adapters = {
		"neotest-plenary",
	},
}

return declarative_layer.apply(L)
