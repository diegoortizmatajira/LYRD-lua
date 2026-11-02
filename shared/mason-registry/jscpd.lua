return {
	name = "jscpd",
	description = "Copy/paste detector — fast Rust-based CLI for code duplication detection "
		.. "across 200+ languages, with JSON/SARIF/HTML reports",
	homepage = "https://jscpd.dev",
	licenses = { "MIT" },
	languages = { "Multiple" },
	categories = { "Linter" },
	source = {
		id = "pkg:cargo/jscpd@5.4.2",
	},
	bin = {
		["jscpd"] = "cargo:jscpd",
	},
}
