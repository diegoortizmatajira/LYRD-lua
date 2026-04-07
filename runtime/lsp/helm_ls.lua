return {
	filetypes = { "helm", "yaml.helm", "yaml.helm-values" },
	settings = {
		["helm-ls"] = {
			yamlls = {
				enabled = true,
				path = "yaml-language-server",
				config = {
					schemas = require("schemastore").yaml.schemas(),
					completion = true,
					hover = true,
					validate = true,
					schemaStore = {
						enable = true,
						url = "https://www.schemastore.org/api/json/catalog.json",
					},
				},
			},
		},
	},
}
