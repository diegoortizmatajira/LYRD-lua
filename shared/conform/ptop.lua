return function()
	local args = { "$FILENAME", "$FILENAME" }
	return {
		command = "ptop",
		args = args,
		stdin = false,
		require_cwd = false,
	}
end
