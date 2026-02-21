return {
	name = "palantir-java-format",
	description = "A modern, lambda-friendly, 120 character Java formatter (fork of google-java-format)",
	homepage = "https://github.com/palantir/palantir-java-format",
	licenses = { "Apache-2.0" },
	languages = { "Java" },
	categories = { "Formatter" },
	source = {
		id = "pkg:github/palantir/palantir-java-format@2.50.0",
	},
	bin = {
		["palantir-java-format"] = "java-jar:palantir-java-format.jar",
	},
}
