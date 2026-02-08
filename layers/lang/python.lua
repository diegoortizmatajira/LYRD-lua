local lsp = require("LYRD.layers.lsp")
local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local utils = require("LYRD.utils")

---@class LYRD.layer.lang.Python: LYRD.setup.Module
local L = {
	name = "Python language",
	use_basedpyright = true,
}

-- Opens the .env file in the current directory
local function open_dotenv()
	utils.open_or_create_file(".env")
end

function L.plugins()
	setup.plugin({
		{
			"mfussenegger/nvim-dap-python",
			dependencies = { "mfussenegger/nvim-dap" },
			config = function()
				-- WARN: Using 'uv' for uv projects support, otherwise skip.
				require("dap-python").setup("uv")
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
		{
			"lukoshkin/pymove.nvim",
			opts = {},
		},
	})
end

function L.preparation()
	local python_lsp = "pyright"
	if L.use_basedpyright then
		python_lsp = "basedpyright"
	end
	lsp.mason_ensure({
		python_lsp,
		"debugpy",
		"pylint",
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
		{ cmd.LYRDCodeSelectEnvironment, ":VenvSelect" },
		{ cmd.LYRDCodeSecrets, open_dotenv },
		{ cmd.LYRDCodeRunSelection, ":LYRDReplNotebookRunCellAndMove" },
		{ cmd.LYRDCodeOrganizeFile, ":PySortFile" },
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
	local python_lsp = "pyright"
	if L.use_basedpyright then
		python_lsp = "basedpyright"
	end
	vim.lsp.enable({ python_lsp, "ruff" })
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
