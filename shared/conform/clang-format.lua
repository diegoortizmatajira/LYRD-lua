local setup = require("LYRD.setup")
local join = require("LYRD.shared.utils").join_paths
---@type conform.FileFormatterConfig
return {
	append_args = {
		string.format("--style=file:%s", join(setup.configs_path, "clang-format")),
	},
}
