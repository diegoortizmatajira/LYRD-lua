local concrete_module = require("LYRD.shared.concrete_module")

local L = concrete_module:new({
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
})

function L:settings()
	concrete_module.settings(self)
	local vimrc_make_cmake_group = vim.api.nvim_create_augroup("vimrc-make-cmake", {})
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = vimrc_make_cmake_group,
		pattern = { "make" },
		command = [[setlocal noexpandtab]],
	})
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		group = vimrc_make_cmake_group,
		pattern = { "CMakeLists.txt" },
		command = [[setlocal filetype=cmake]],
	})
end

return L
