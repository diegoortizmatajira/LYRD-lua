local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")

local L = { name = "Lua Language" }

function L.plugins(s)
	local library_list = {
		-- See the configuration section for more details
		-- Load luvit types when the `vim.uv` word is found
		{ path = "luvit-meta/library", words = { "vim%.uv" } },
	}
	-- Adds all the loaded layers
	for _, lib in ipairs(s.layers) do
		table.insert(library_list, lib)
	end

	setup.plugin(s, {
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = library_list,
			},
		},
		{ "Bilal2453/luvit-meta", lazy = true },
	})
end

function L.preparation(_)
	lsp.mason_ensure({
		"lua-language-server",
		"luacheck",
		"luaformatter",
		"luau-lsp",
		"stylua",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.stylua,
	})
end

function L.settings(_) end

function L.complete(_)
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
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = { enable = false },
			},
		},
	})
end

return L
