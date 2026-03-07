local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Lua Language",
	required_plugins = {
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {},
			init = function()
				vim.g.lazydev_enabled = true
			end,
		},
		{ "Bilal2453/luvit-meta", lazy = true },
	},
	required_mason_packages = {
		"lua-language-server",
		"luacheck",
		"luaformatter",
		"luau-lsp",
		"stylua",
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
}

function L.preparation()
	local lsp = require("LYRD.layers.lsp")
	lsp.format_with_conform("lua", { "stylua" })
end

return declarative_layer.apply(L)
