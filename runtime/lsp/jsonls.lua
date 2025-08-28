return {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = {
				enabled = true,
			},
		},
	},
}
