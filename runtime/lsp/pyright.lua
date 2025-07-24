local virtual_env = os.getenv("VIRTUAL_ENV") or ""

return {
	settings = {
		pyright = {
			disableOrganizeImports = false,
		},
		python = {
			analysis = {
				autoImportCompletions = true,
				typeCheckingMode = "standard",
				useLibraryCodeForTypes = true,
			},
			venvPath = virtual_env,
		},
	},
}
