local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")

local L = { name = "Python language" }
local python_line_length = 120

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
		-- "python-lsp-server",
		"yapf",
	})

	local null_ls = require("null-ls")

	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.yapf,
		null_ls.builtins.diagnostics.pylint.with({
			command = "python",
			args = { "-m", "pylint", "--from-stdin", "$FILENAME", "-f", "json" },
		}),
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-python"))
end

function L.keybindings(_) end

function L.complete(_)
	-- lsp.enable("pylsp", {
	-- 	settings = {
	-- 		pylsp = {
	-- 			plugins = {
	-- 				pycodestyle = {
	-- 					ignore = { "E501" },
	-- 					maxLineLength = python_line_length,
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- })
	local virtual_env = os.getenv("VIRTUAL_ENV") or ""
	lsp.enable("pyright", {
		settings = {
			pyright = {
				disableOrganizeImports = false,
			},
			python = {
				venvPath = virtual_env,
				analysis = {
					autoImportCompletions = true,
					useLibraryCodeForTypes = true,
					typeCheckingMode = "off",
				},
			},
		},
	})
	require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
end

return L
