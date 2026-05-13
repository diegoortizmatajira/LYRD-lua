local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "CMake Language",
	required_mason_packages = {
		"cmake-language-server",
	},
	required_treesitter_parsers = {
		"make",
		"cmake",
	},
	required_enabled_lsp_servers = {
		"cmake",
	},
	required_filetype_definitions = {
		filename = {
			["CMakeLists.txt"] = "cmake",
		},
	},
}

function L.settings()
	local vimrc_make_cmake_group = vim.api.nvim_create_augroup("vimrc-make-cmake", {})
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = vimrc_make_cmake_group,
		pattern = { "make" },
		command = [[setlocal noexpandtab]],
	})
end

return declarative_layer.apply(L)
