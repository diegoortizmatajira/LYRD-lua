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
		"yapf",
	})

	local null_ls = require("null-ls")
	local h = require("null-ls.helpers")

	lsp.null_ls_register_sources({
		-- Custom Yapf to use 120 as max line length
		null_ls.builtins.formatting.yapf.with({
			args = h.range_formatting_args_factory({
				"--quiet",
				"--style={based_on_style: google, column_limit: 120}",
			}, "--lines", nil, { use_rows = true, delimiter = "-" }),
		}),
		-- Custom pylint to use the module in the environment (instead of the Mason one). Requires to install pylint manually.
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
