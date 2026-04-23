return {
	name = "pasfmt",
	description = "pasfmt is a complete and opinionated formatter for Delphi code.",
	homepage = "https://github.com/palantir/palantir-java-format",
	licenses = { "Apache-2.0" },
	languages = { "Pascal" },
	categories = { "Formatter" },
	source = {
		id = "pkg:github/integrated-application-development/pasfmt@v0.7.0",
		asset = {
			{
				target = "linux_x64",
				file = 'pasfmt-{{ version | strip_prefix "v" }}-x86_64-unknown-linux-gnu.tar.gz',
				bin = 'pasfmt-{{ version | strip_prefix "v" }}-x86_64-unknown-linux-gnu/pasfmt',
			},
		},
	},
	bin = {
		["pasfmt"] = "exec:{{source.asset.bin}}",
	},
}
