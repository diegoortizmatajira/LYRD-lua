local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "CiCd",
	required_mason_packages = {
		"actionlint",
		"gitlab-ci-ls",
		"gh-actions-language-server",
		"azure-pipelines-language-server",
	},
	required_treesitter_parsers = {},
	required_enabled_lsp_servers = {
		{
			"gitlab_ci_ls",
			config = { filetypes = { "yaml.gitlab" } },
		},
		{
			"gh_actions_ls",
			config = { filetypes = { "yaml.github" } },
		},
		{
			"azure_pipelines_ls",
			config = { filetypes = { "yaml.azure" } },
		},
	},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.actionlint",
	},
	required_filetype_definitions = {
		pattern = {
			["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
			[".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
			[".*/azure%-pipelines%.ya?ml"] = "yaml.azure",
		},
	},
}

return declarative_layer.apply(L)
