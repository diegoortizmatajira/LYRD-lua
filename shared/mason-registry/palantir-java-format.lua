return {
	name = "palantir-java-format",
	description = "A modern, lambda-friendly, 120 character Java formatter (fork of google-java-format)",
	homepage = "https://github.com/palantir/palantir-java-format",
	licenses = { "Apache-2.0" },
	languages = { "Java" },
	categories = { "Formatter" },
	source = {
		id = "pkg:generic/palantir-java-format@2.89.0",
		download = {
			{
				target = "linux_x64",
				files = {
					["palantir-java-format-{{version}}.bin"] = "https://repo1.maven.org/maven2/com/palantir/javaformat/palantir-java-format-native/{{version}}/palantir-java-format-native-{{version}}-nativeImage-linux-glibc_x86-64.bin",
				},
			},
			{
				target = "linux_arm64",
				files = {
					["palantir-java-format-{{version}}.bin"] = "https://repo1.maven.org/maven2/com/palantir/javaformat/palantir-java-format-native/{{version}}/palantir-java-format-native-{{version}}-nativeImage-linux-glibc_aarch64.bin",
				},
			},
			{
				target = "darwin_arm64",
				files = {
					["palantir-java-format-{{version}}.bin"] = "https://repo1.maven.org/maven2/com/palantir/javaformat/palantir-java-format-native/{{version}}/palantir-java-format-native-{{version}}-nativeImage-macos_aarch64.bin",
				},
			},
		},
	},
	bin = {
		["palantir-java-format"] = "exec:palantir-java-format-{{version}}.bin",
	},
}
