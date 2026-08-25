
return {
	name = "httpgenerator",
	description = "HTTP File Generator",
	homepage = "https://github.com/christianhelle/httpgenerator",
	licenses = { "MIT License" },
	languages = { "openapi" },
	categories = { "Tool" },
	source = {
		id = "pkg:cargo/httpgenerator@1.1.0",
	},
	bin = {
		["httpgenerator"] = "cargo:httpgenerator",
	},
}
