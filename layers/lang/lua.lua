local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")

local L = {
	name = "Lua Language",
}

function L.plugins()
	setup.plugin({
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {},
			init = function()
				vim.g.lazydev_enabled = true
			end,
		},
		{ "Bilal2453/luvit-meta", lazy = true },
	})
end

function L.preparation()
	lsp.mason_ensure({
		"lua-language-server",
		"luacheck",
		"luaformatter",
		"luau-lsp",
		"stylua",
	})
	lsp.format_with_conform("lua", { "stylua" })
end

function L.complete()
	vim.lsp.enable("lua_ls")
end

return L
