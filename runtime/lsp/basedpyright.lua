local virtual_env = os.getenv("VIRTUAL_ENV") or ""

return {
	settings = {
		basedpyright = {
			disableOrganizeImports = false,
			analysis = {
				autoImportCompletions = true,
				typeCheckingMode = "standard",
				useLibraryCodeForTypes = true,
			},
		},
		python = {
			venvPath = virtual_env,
		},
	},
}
