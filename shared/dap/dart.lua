local config = {
	adapter = {
		type = "executable",
		command = vim.fn.exepath("dart-debug-adapter"),
		args = { "flutter" },
	},

	default_configuration = {

		{
			type = "dart",
			request = "launch",
			name = "Launch flutter",
			dartSdkPath = "home/flutter/bin/cache/dart-sdk/",
			flutterSdkPath = "home/flutter",
			program = "${workspaceFolder}/lib/main.dart",
			cwd = "${workspaceFolder}",
		},
	},
}

function config.setup(filetypes)
	local dap = require("dap")
	dap.adapters.dart = config.adapter
	for _, ft in ipairs(filetypes) do
		dap.configurations[ft] = config.default_configuration
	end
end
return config
