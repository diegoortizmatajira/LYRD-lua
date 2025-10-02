local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.lang.Python: LYRD.setup.Module
local L = { name = "Python language" }

-- Opens the .env file in the current directory
local function open_dotenv()
	vim.cmd("e .env")
end

function L.plugins()
	setup.plugin({
		-- {
		-- 	"mfussenegger/nvim-dap-python",
		-- 	dependencies = { "mfussenegger/nvim-dap" },
		-- 		config = function()
		-- 			require("dap-python").setup()
		-- 			table.insert(require("dap").configurations.python, {
		-- 				type = "python",
		-- 				request = "launch",
		-- 				name = "My custom launch configuration",
		-- 				program = "${file}",
		-- 			})
		-- 		end,
		-- 	ft = "python",
		-- },
		{
			"nvim-neotest/neotest-python",
			ft = "python",
			python = nil,
		},
		{
			"linux-cultist/venv-selector.nvim",
			dependencies = {
				"neovim/nvim-lspconfig",
				"mfussenegger/nvim-dap",
				"nvim-telescope/telescope.nvim",
			},
			lazy = false,
			opts = {
				name = { "venv", ".venv" },
			},
			ft = "python",
		},
		{
			"raimon49/requirements.txt.vim",
		},
		{
			"benomahony/uv.nvim",
			opts = {
				picker_integration = true,
				keymaps = false,
			},
		},
	})
end

function L.preparation()
	lsp.mason_ensure({
		"debugpy",
		"pylint",
		"pyright",
		"pydocstyle",
		"ruff",
		"yapf",
	})

	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"python",
		"htmldjango",
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

function L.settings()
	commands.implement("python", {
		{ cmd.LYRDCodeFixImports, ":PyrightOrganizeImports" },
		{ cmd.LYRDCodeSelectEnvironment, ":VenvSelect" },
		{ cmd.LYRDCodeSecrets, open_dotenv },
		{ cmd.LYRDCodeRunSelection, ":LYRDReplNotebookRunCellAndMove" },
		{
			cmd.LYRDCodeTooling,
			function()
				require("uv").pick_uv_commands()
			end,
		},
	})
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.python_tasks"))
end

function L.complete()
	vim.lsp.enable({ "pyright", "ruff" })
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
