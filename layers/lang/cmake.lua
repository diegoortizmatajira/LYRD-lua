local lsp = require("LYRD.layers.lsp")

local L = { name = "CMake Language" }

function L.plugins() end

function L.preparation()
	lsp.mason_ensure({
		"cmake-language-server",
	})
end

function L.settings()
	-- make/cmake
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

function L.keybindings() end

function L.complete()
	lsp.enable("cmake", {})
end

return L
