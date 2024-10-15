local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Python language" }

function L.plugins(s)
	setup.plugin(s, {
		"mfussenegger/nvim-dap-python",
		"nvim-neotest/neotest-python",
	})
end

function L.settings(s)
	lsp.mason_ensure({
		"debugpy",
		"pylint",
		"pyright",
		"ruff",
	})

	local null_ls = require("null-ls")

	lsp.null_ls_register_sources({
		-- Custom pylint to use the module in the environment (instead of the Mason one). Requires to install pylint manually.
		null_ls.builtins.diagnostics.pylint.with({
			command = "python",
			args = {
				"-m",
				"pylint",
				"--rcfile",
				setup.configs_path .. "/pylintrc",
				"--from-stdin",
				"$FILENAME",
				"-f",
				"json",
			},
		}),
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-python"))

	commands.implement(s, "python", {
		{ cmd.LYRDCodeFixImports, ":PyrightOrganizeImports" },
	})
end

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
					typeCheckingMode = "standard",
					useLibraryCodeForTypes = true,
				},
			},
		},
	})
	lsp.enable("ruff", {
		init_options = {
			settings = {
				lineLength = 120,
				lint = {
					enable = true,
					preview = true,
				},
				format = {
					preview = true,
				},
			},
		},
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client == nil then
				return
			end
			if client.name == "ruff" then
				-- Disable hover in favor of Pyright
				client.server_capabilities.hoverProvider = false
			end
		end,
		desc = "LSP: Disable hover capability from Ruff",
	})
	require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
end

return L
