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
		function()
			-- selene's on_output crashes on `vim.split(nil, ...)` when a clean
			-- lint run produces empty stdout (none-ls normalizes "" to nil).
			local selene = require("null-ls.builtins.diagnostics.selene")
			local original_on_output = selene._opts.on_output
			return selene.with({
				on_output = function(params, done)
					if not params.output or params.output == "" then
						return done({})
					end
					return original_on_output(params, done)
				end,
			})
		end,
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
