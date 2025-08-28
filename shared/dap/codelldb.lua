local config = {
	adapter = {
		type = "server",
		port = "${port}",
		executable = {
			command = "codelldb",
			args = { "--port", "${port}" },
		},
	},
	default_configuration = {
		{
			name = "Select executable to run",
			type = "codelldb",
			request = "launch",

			program = function()
				return vim.fn.input("", vim.fn.getcwd(), "file")
			end,

			args = { "--log_level=all" },
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			terminal = "integrated",

			pid = function()
				local handle = io.popen("pgrep hw$")
				local result = handle:read()
				handle:close()
				return result
			end,
		},
	},
}
function config.setup(filetypes)
	local dap = require("dap")
	dap.adapters.codelldb = config.adapter
	for _, ft in ipairs(filetypes) do
		dap.configurations[ft] = config.default_configuration
	end
end
return config
