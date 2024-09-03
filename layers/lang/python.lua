local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")

local L = { name = "Python language" }

function L.plugins(s)
	setup.plugin(s, {
		"mfussenegger/nvim-dap-python",
		"nvim-neotest/neotest-python",
	})
end

function L.settings(_)
	lsp.mason_ensure({
		"debugpy",
		"pylint",
		"pyright",
		"python-lsp-server",
		"yapf",
	})
	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.yapf,
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-python"))
end

function L.keybindings(_) end

function L.complete(_)
	lsp.enable("pyright", { settings = { python = { analysis = { typeCheckingMode = "off" } } } })
	require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
end

return L
