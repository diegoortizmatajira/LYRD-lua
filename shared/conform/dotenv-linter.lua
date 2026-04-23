return {
	command = "dotenv-linter",
	args = { "fix", "--no-backup", "$FILENAME" },
	stdin = false,
}
