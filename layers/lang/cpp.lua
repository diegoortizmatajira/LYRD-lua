local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")

local L = { name = "C and C++" }

function L.plugins()
	setup.plugin({})
end

function L.preparation()
	lsp.mason_ensure({
		"clangd",
		"codelldb",
	})
	lsp.format_with_conform({ "cpp", "c" }, {
		"clang-format",
	})
end

function L.settings()
	commands.implement("*", {
		-- { cmd.LYRDXXXX, ":XXXXX" },
	})
end

function L.keybindings() end

function L.complete()
	vim.lsp.enable("clangd")
end
return L
