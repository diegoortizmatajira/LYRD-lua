return {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"awesome",
					"client",
					"mouse",
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
}
