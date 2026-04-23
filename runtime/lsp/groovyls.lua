local lsp = require("LYRD.layers.lsp")
local join = require("LYRD.shared.utils").join_paths

local pkg_path = lsp.get_pkg_path("groovy-language-server")

return {
	cmd = {
		"java",
		"-jar",
		join(pkg_path, "build", "libs", "groovy-language-server-all.jar"),
	},
	filetypes = { "groovy" },
	root_markers = {
		"build.gradle",
		"settings.gradle",
		"build.gradle.kts",
		"settings.gradle.kts",
		"pom.xml",
		"gradlew",
		".git",
	},
}
