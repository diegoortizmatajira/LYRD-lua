return {
	command = "php-cs-fixer",
	args = {
		"fix",
		"$FILENAME",
	},
	stdin = false, -- php-cs-fixer does NOT support stdin
	cwd = function(ctx)
		return vim.fn.getcwd() -- force current working directory as root
	end,
}
