local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local format = require("LYRD.layers.format")

local L = { name = "Python language" }

function L.plugins(s)
	setup.plugin(s, { "mfussenegger/nvim-dap-python" })
end

function L.settings(_)
	format.add_formatters("python", { require("formatter.filetypes.python").yapf })
	format.add_formatters("htmldjango", { require("formatter.filetypes.html").prettier })
	lsp.mason_ensure({
		"debugpy",
		"pylint",
		"pyright",
		"python-lsp-server",
	})
end

function L.keybindings(_) end

function L.complete(_)
	lsp.enable("pyright", { settings = { python = { analysis = { typeCheckingMode = "off" } } } })
	require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
end

return L
