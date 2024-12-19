local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local virtual_env = os.getenv("VIRTUAL_ENV") or ""

local L = { name = "Python language" }

-- Opens the .env file in the current directory
function L.open_dotenv()
	vim.cmd("e .env")
end

function L.plugins(s)
	setup.plugin(s, {
		{
			"mfussenegger/nvim-dap-python",
			config = function()
				require("dap-python").setup()
				table.insert(require("dap").configurations.python, {
					type = "python",
					request = "launch",
					name = "My custom launch configuration",
					program = "${file}",
				})
			end,
			ft = "python",
		},
		{
			"nvim-neotest/neotest-python",
			ft = "python",
		},
		{
			"linux-cultist/venv-selector.nvim",
			dependencies = {
				"neovim/nvim-lspconfig",
				"mfussenegger/nvim-dap",
				"mfussenegger/nvim-dap-python", --optional
				"nvim-telescope/telescope.nvim",
			},
			lazy = false,
			branch = "regexp", -- This is the regexp branch, use this for the new version
			opts = {
				name = { "venv", ".venv" },
			},
			ft = "python",
		},
	})
end

function L.preparation(_)
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
end

function L.settings(s)
	commands.implement(s, "python", {
		{ cmd.LYRDCodeFixImports, ":PyrightOrganizeImports" },
		{ cmd.LYRDCodeSelectEnvironment, ":VenvSelect" },
		{ cmd.LYRDCodeSecrets, L.open_dotenv },
	})
end

function L.complete(_)
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
end

return L
