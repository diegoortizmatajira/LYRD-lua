return {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			diagnostics = {
				library_files = false,
			},
			telemetry = {
				enable = false,
			},
			workspace = {
				checkThirdParty = false,
				library = {
					["/github/workspace/deps/neodev.nvim/types/stable"] = true,
					["${3rd}/busted/library"] = true,
					["${3rd}/luassert/library"] = true,
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
		},
	},
}
