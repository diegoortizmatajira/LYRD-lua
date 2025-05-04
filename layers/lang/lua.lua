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
	lsp.enable("lua_ls", {
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
					-- Setup your lua path
					path = vim.split(package.path, ";"),
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim", "awesome", "client", "mouse" },
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = { enable = false },
			},
		},
	})
end

return L
