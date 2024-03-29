local lsp = require("LYRD.layers.lsp")

local L = { name = "Lua Language" }

function L.plugins(_) end

function L.settings(s)
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
