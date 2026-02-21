return {
	name = "palantir-java-format",
	description = "A modern, lambda-friendly, 120 character Java formatter (fork of google-java-format)",
	homepage = "https://github.com/palantir/palantir-java-format",
	licenses = { "Apache-2.0" },
	languages = { "Java" },
	categories = { "Formatter" },
	source = {
		id = "pkg:generic/palantir-java-format@2.88.0",
		build = {
			{
				target = "linux_x64",
				run = 'curl -fsSL -o palantir-java-format "https://repo1.maven.org/maven2/com/palantir/javaformat/palantir-java-format-native/2.88.0/palantir-java-format-native-2.88.0-nativeImage-linux-glibc_x86-64.bin" && chmod +x palantir-java-format',
			},
			{
				target = "linux_arm64",
				run = 'curl -fsSL -o palantir-java-format "https://repo1.maven.org/maven2/com/palantir/javaformat/palantir-java-format-native/2.88.0/palantir-java-format-native-2.88.0-nativeImage-linux-glibc_aarch64.bin" && chmod +x palantir-java-format',
			},
			{
				target = "darwin_arm64",
				run = 'curl -fsSL -o palantir-java-format "https://repo1.maven.org/maven2/com/palantir/javaformat/palantir-java-format-native/2.88.0/palantir-java-format-native-2.88.0-nativeImage-macos_aarch64.bin" && chmod +x palantir-java-format',
			},
		},
	},
	bin = {
		["palantir-java-format"] = "palantir-java-format",
	},
}
