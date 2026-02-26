local setup = require("LYRD.setup")
local utils = require("LYRD.utils")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

---@class LYRD.layer.LSP: LYRD.setup.Module
local L = {
	name = "LSP",
	required_tools = {},
	null_ls_sources = {},
	null_ls_registered = {},
	conform_formatters_by_ft = {},
	conform_formatters = {},
	enable_usage_hints = false,
}

local mason_opts = {
	ui = {
		check_outdated_packages_on_open = true,
		width = 0.8,
		height = 0.9,
		border = "rounded",
		keymaps = {
			toggle_package_expand = "<CR>",
			install_package = "i",
			update_package = "u",
			check_package_version = "c",
			update_all_packages = "U",
			check_outdated_packages = "C",
			uninstall_package = "X",
			cancel_installation = "<C-c>",
			apply_language_filter = "<C-f>",
		},
		icons = {
			package_installed = icons.status.checked,
			package_pending = icons.status.unknown,
			package_uninstalled = icons.status.unchecked,
		},
	},

	-- NOTE: should be available in $PATH
	install_root_dir = utils.join_paths(vim.fn.stdpath("data"), "mason"),

	pip = {
		upgrade_pip = false,
		-- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
		-- and is not recommended.
		--
		-- Example: { "--proxy", "https://proxyserver" }
		install_args = {},
	},

	-- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
	-- debugging issues with package installations.
	log_level = vim.log.levels.INFO,

	-- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
	-- packages that are requested to be installed will be put in a queue.
	max_concurrent_installers = 4,

	-- [Advanced setting]
	-- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
	-- multiple registries, the registry listed first will be used.
	registries = {
		"lua:LYRD.shared.mason-registry",
		"github:crashdummyy/mason-registry",
		"github:nvim-java/mason-registry",
		"github:mason-org/mason-registry",
	},

	-- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
	-- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
	providers = {
		"mason.providers.registry-api",
		"mason.providers.client",
	},

	github = {
		-- The template URL to use when downloading assets from GitHub.
		-- The placeholders are the following (in order):
		-- 1. The repository (e.g. "rust-lang/rust-analyzer")
		-- 2. The release version (e.g. "v0.3.0")
		-- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
		download_url_template = "https://github.com/%s/releases/download/%s/%s",
	},
}

local function add_mason_bin_to_path(append)
	local p = utils.join_paths(mason_opts.install_root_dir, "bin")
	utils.include_in_system_path(p, append)
end

local plugged_capabilities = function()
	local result = vim.lsp.protocol.make_client_capabilities()
	result.textDocument.completion.completionItem.snippetSupport = true
	result.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	}
	result.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	result.textDocument = result.textDocument or {}
	result.textDocument.codeLens = {
		dynamicRegistration = true,
		resolveProvider = true,
	}

	result.workspace = result.workspace or {}
	result.workspace.codeLens = {
		refreshSupport = true,
	}
	return result
end

local function setup_default_providers()
	local null_ls = require("null-ls")
	L.null_ls_register_sources({
		null_ls.builtins.formatting.yamlfmt,
		null_ls.builtins.formatting.clang_format,
	})
end

function L.plug_capabilities(plug_handler)
	plugged_capabilities = plug_handler(plugged_capabilities)
end

local function toggle_diagnostic_lines()
	local new_config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_config })
end

local function exclude_lsp_lines_from_filetypes(filetypes)
	for _, filetype in ipairs(filetypes) do
		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetype,
			callback = function()
				vim.diagnostic.config({ virtual_lines = false })
			end,
		})
	end
end

function L.get_pkg_path(pkg, ...)
	return utils.join_paths(vim.fn.expand("$MASON"), "packages", pkg, ...)
end

local function usage_text_format(symbol)
	local res = {}

	local round_start = { "", "SymbolUsageRounding" }
	local round_end = { "", "SymbolUsageRounding" }

	-- Indicator that shows if there are any other symbols in the same line
	local stacked_functions_content = symbol.stacked_count > 0 and ("+%s"):format(symbol.stacked_count) or ""

	table.insert(res, round_start)

	if symbol.references then
		local usage = symbol.references <= 1 and "usage" or "usages"
		local num = symbol.references == 0 and "no" or symbol.references
		table.insert(res, { "󰌹 ", "SymbolUsageRef" })
		table.insert(res, { ("%s %s"):format(num, usage), "SymbolUsageContent" })
	end

	if symbol.definition then
		if #res > 0 then
			table.insert(res, { " ", "SymbolUsageContent" })
		end
		table.insert(res, { "󰳽 ", "SymbolUsageDef" })
		table.insert(res, { symbol.definition .. " defs", "SymbolUsageContent" })
	end

	if symbol.implementation then
		if #res > 0 then
			table.insert(res, { " ", "SymbolUsageContent" })
		end
		table.insert(res, { "󰡱 ", "SymbolUsageImpl" })
		table.insert(res, { symbol.implementation .. " impls", "SymbolUsageContent" })
	end

	if stacked_functions_content ~= "" then
		if #res > 0 then
			table.insert(res, { " ", "SymbolUsageContent" })
		end
		table.insert(res, { " ", "SymbolUsageImpl" })
		table.insert(res, { stacked_functions_content, "SymbolUsageContent" })
	end
	table.insert(res, round_end)

	return res
end

function L.organize_imports()
	vim.lsp.buf.code_action({ only = { "source.organizeImports" } })
end

function L.plugins()
	local SymbolKind = vim.lsp.protocol.SymbolKind
	setup.plugin({
		{ "neovim/nvim-lspconfig" },
		{
			"mason-org/mason.nvim",
			version = "2.*",
			config = false,
		},
		{
			"mason-org/mason-lspconfig.nvim",
			config = false,
			version = "2.*",
			dependencies = {
				"mason-org/mason.nvim",
				"neovim/nvim-lspconfig",
			},
		},
		{
			"nvimtools/none-ls.nvim",
			dependencies = {
				"nvimtools/none-ls-extras.nvim",
			},
			config = false,
		},
		{
			"jay-babu/mason-null-ls.nvim",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = {
				"williamboman/mason.nvim",
				"nvimtools/none-ls.nvim",
			},
			config = false,
		},
		{
			"whoissethdaniel/mason-tool-installer.nvim",
			config = false,
			dependencies = { "williamboman/mason.nvim" },
		},
		{
			"folke/trouble.nvim",
			opts = {},
		},
		{
			"VidocqH/lsp-lens.nvim",
			opts = {
				enable = false,
			},
			cmd = { "LspLensToggle" },
		},
		{
			"kosayoda/nvim-lightbulb",
			opts = {
				action_kinds = { -- show only for relevant code actions.
					"quickfix",
				},
				ignore = {
					ft = { "lua", "markdown" }, -- ignore filetypes with bad code actions.
				},
				autocmd = {
					enabled = true,
					updatetime = 100,
				},
				sign = { enabled = true },
				virtual_text = {
					enabled = false,
					text = icons.other.lightbulb,
				},
			},
		},
		{
			"aznhe21/actions-preview.nvim",
			opts = {
				telescope = {
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						width = 0.8,
						height = 0.9,
						prompt_position = "top",
						preview_cutoff = 20,
					},
				},
			},
		},
		{
			"stevearc/conform.nvim",
			config = false,
			init = function()
				-- If you want the formatexpr, here is the place to set it
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},
		{
			"Wansmer/symbol-usage.nvim",
			enabled = L.enable_usage_hints,
			event = "LspAttach", -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
			opts = {
				---@type lsp.SymbolKind[] Symbol kinds what need to be count (see `lsp.SymbolKind`)
				kinds = { SymbolKind.Function, SymbolKind.Method, SymbolKind.Interface, SymbolKind.Class },
				text_format = usage_text_format,
				references = { enabled = true, include_declaration = false },
				definition = { enabled = true },
				implementation = { enabled = true },
			},
			init = function()
				local function h(name)
					return vim.api.nvim_get_hl(0, { name = name })
				end

				-- hl-groups can have any name
				-- Stylua will mess up the formatting here, so disable it
                -- stylua: ignore start
				vim.api.nvim_set_hl(0, "SymbolUsageRounding", { fg = h("CursorLine").bg, italic = true })
				vim.api.nvim_set_hl( 0, "SymbolUsageContent", { bg = h("CursorLine").bg, fg = h("Comment").fg, italic = true })
				vim.api.nvim_set_hl( 0, "SymbolUsageRef", { fg = h("Function").fg, bg = h("CursorLine").bg, italic = true })
				vim.api.nvim_set_hl(0, "SymbolUsageDef", { fg = h("Type").fg, bg = h("CursorLine").bg, italic = true })
				vim.api.nvim_set_hl( 0, "SymbolUsageImpl", { fg = h("@keyword").fg, bg = h("CursorLine").bg, italic = true })
				-- stylua: ignore end
			end,
		},
	})
end

function L.preparation()
	add_mason_bin_to_path()
	L.mason_ensure({
		"bash-language-server",
		"editorconfig-checker",
		"vim-language-server",
	})
	setup_default_providers()
end

function L.settings()
	local lspconfig = require("lspconfig")
	lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
		capabilities = plugged_capabilities(),
	})

	require("mason").setup(mason_opts) -- Recommended not to lazy load
	require("mason-tool-installer").setup({
		ensure_installed = L.required_tools,
	})
	require("mason-lspconfig").setup({
		automatic_enable = false,
	})

	-- Configures the null language server
	local null_ls = require("null-ls")
	null_ls.setup({
		sources = L.null_ls_sources,
	})
	for _, custom_register in ipairs(L.null_ls_registered) do
		null_ls.register(custom_register)
	end

	require("mason-null-ls").setup({
		ensure_installed = {},
		automatic_installation = true,
	})

	require("conform").setup({
		formatters_by_ft = L.conform_formatters_by_ft,
		formatters = L.conform_formatters,
		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},
	})

	local signs = {
		{ name = "DiagnosticSignError", text = icons.diagnostic.error },
		{ name = "DiagnosticSignWarn", text = icons.diagnostic.warning },
		{ name = "DiagnosticSignHint", text = icons.diagnostic.hint },
		{ name = "DiagnosticSignInfo", text = icons.diagnostic.info },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		-- show signs
		signs = { active = signs },
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		virtual_text = false,
		current_line = true,
		virtual_lines = true,
	}

	vim.diagnostic.config(config)
	exclude_lsp_lines_from_filetypes({ "lazy" })

	vim.o.winborder = "rounded"

	-- Custom hover that filters out LSP clients with empty results
	local function filtered_hover()
		local params = vim.lsp.util.make_position_params(0, "utf-16")
		vim.lsp.buf_request_all(0, "textDocument/hover", params, function(results, ctx)
			local entries = {}
			for client_id, resp in pairs(results) do
				if not resp.error and resp.result and resp.result.contents then
					local lines = vim.lsp.util.convert_input_to_markdown_lines(resp.result.contents)
					local has_content = false
					for _, line in ipairs(lines) do
						if vim.trim(line) ~= "" then
							has_content = true
							break
						end
					end
					if has_content then
						table.insert(entries, { client_id = client_id, lines = lines })
					end
				end
			end
			if #entries == 0 then
				return
			end
			local display = {}
			for i, entry in ipairs(entries) do
				if #entries > 1 then
					local client = vim.lsp.get_client_by_id(entry.client_id)
					local name = client and client.name or tostring(entry.client_id)
					if i > 1 then
						table.insert(display, "---")
					end
					table.insert(display, ("# %s"):format(name))
				end
				vim.list_extend(display, entry.lines)
			end
			vim.lsp.util.open_floating_preview(display, "markdown", {
				focus_id = "textDocument/hover",
			})
		end)
	end
	L.filtered_hover = filtered_hover

	if L.enable_usage_hints then
		local ui = require("LYRD.layers.lyrd-ui")
		ui.register_decoration_togglers("*", {
			function()
				-- Toggle symbol usage display
				require("symbol-usage").toggle()
			end,
		})
	end

	commands.implement("*", {
		{ cmd.LYRDToolManager, ":Mason" },
		{ cmd.LYRDBufferFormat, L.conform_format_handler() },
		{ cmd.LYRDLSPFindReferences, commands.wrap(vim.lsp.buf.references) },
		{ cmd.LYRDLSPFindCodeActions, commands.wrap(require("actions-preview").code_actions) },
		{ cmd.LYRDLSPFindRangeCodeActions, commands.wrap(vim.lsp.buf.range_code_action) },
		{ cmd.LYRDLSPFindLineDiagnostics, commands.wrap(vim.diagnostic.show_line_diagnostics) },
		{ cmd.LYRDLSPFindDocumentDiagnostics, ":Trouble diagnostics toggle filter.buf=0" },
		{ cmd.LYRDLSPFindWorkspaceDiagnostics, ":Trouble diagnostics toggle" },
		{ cmd.LYRDLSPFindImplementations, commands.wrap(vim.lsp.buf.implementation) },
		{ cmd.LYRDLSPFindDefinitions, commands.wrap(vim.lsp.buf.definition) },
		{ cmd.LYRDLSPFindDeclaration, commands.wrap(vim.lsp.buf.declaration) },
		{ cmd.LYRDLSPHoverInfo, filtered_hover },
		{ cmd.LYRDLSPSignatureHelp, commands.wrap(vim.lsp.buf.signature_help) },
		{ cmd.LYRDLSPFindTypeDefinition, commands.wrap(vim.lsp.buf.type_definition) },
		{ cmd.LYRDLSPRename, commands.wrap(vim.lsp.buf.rename) },
		{
			cmd.LYRDLSPGotoNextDiagnostic,
			function()
				vim.diagnostic.jump({ count = 1 })
			end,
		},
		{
			cmd.LYRDLSPGotoPrevDiagnostic,
			function()
				vim.diagnostic.jump({ count = -1 })
			end,
		},
		{ cmd.LYRDLSPShowDocumentDiagnosticLocList, ":Trouble diagnostics toggle filter.buf=0" },
		{ cmd.LYRDLSPShowWorkspaceDiagnosticLocList, ":Trouble diagnostics toggle" },
		{ cmd.LYRDViewLocationList, ":Trouble loclist toggle" },
		{ cmd.LYRDViewQuickFixList, ":Trouble qflist toggle" },
		{ cmd.LYRDDiagnosticLinesToggle, toggle_diagnostic_lines },
		{ cmd.LYRDLSPToggleLens, ":LspLensToggle" },
		{ cmd.LYRDCodeFixImports, L.organize_imports },
	})
end

function L.mason_ensure(tools)
	for _, tool in ipairs(tools) do
		table.insert(L.required_tools, tool)
	end
end

function L.null_ls_register_sources(sources)
	for _, source in ipairs(sources) do
		table.insert(L.null_ls_sources, source)
	end
end

function L.null_ls_register(custom_register)
	table.insert(L.null_ls_registered, custom_register)
end

function L.register_code_actions(filetypes, fn)
	local null_ls = require("null-ls")
	L.null_ls_register({
		method = null_ls.methods.CODE_ACTION,
		filetypes = filetypes,
		generator = {
			fn = fn,
		},
	})
end

--- Customizes the formatter for a given formatter name.
--- @param formatter_name string Name of the formatter to customize
--- @param custom_formatter table|function Custom formatter function
function L.customize_formatter(formatter_name, custom_formatter)
	L.conform_formatters[formatter_name] = custom_formatter
end

--- Configures the given LSP server to format buffers for a given filetype.
--- @param filetype string|string[] filetype(s) to format
--- @param lsp_name string name of the LSP server
--- @param pre_logic function|nil function to execute before formatting
--- @param post_logic function|nil function to execute after formatting
function L.format_with_lsp(filetype, lsp_name, pre_logic, post_logic)
	commands.implement(filetype, {
		{ cmd.LYRDBufferFormat, L.lsp_format_handler(lsp_name, pre_logic, post_logic) },
	})
end

--- Configures the given LSP server to format buffers for a given filetype.
--- @param filetype string | string[] filetype(s) to format
--- @param format_settings table Settings for the formatter
--- @param pre_logic function|nil function to execute before formatting
--- @param post_logic function|nil function to execute after formatting
function L.format_with_conform(filetype, format_settings, pre_logic, post_logic)
	if type(filetype) == "string" then
		L.conform_formatters_by_ft[filetype] = format_settings
	elseif type(filetype) == "table" then
		for _, ft in pairs(filetype) do
			L.conform_formatters_by_ft[ft] = format_settings
		end
	end
	if pre_logic or post_logic then
		commands.implement(filetype, {
			{ cmd.LYRDBufferFormat, L.conform_format_handler(pre_logic, post_logic) },
		})
	end
end

function L.complete()
	-- Added here to be executed after every plugin code has been initialized.
	vim.diagnostic.config({ virtual_text = false })
end

--- Returns a handler that format using the given lsp
--- @param server_name string name of the LSP server
--- @param pre_logic function|nil function to execute before formatting
--- @param post_logic function|nil function to execute after formatting
function L.lsp_format_handler(server_name, pre_logic, post_logic)
	-- Returns a handler that format using the given lsp
	return function()
		if pre_logic then
			pre_logic()
		end
		vim.lsp.buf.format({
			filter = function(client)
				return client.name == server_name
			end,
			async = false,
		})
		if post_logic then
			post_logic()
		end
	end
end

--- Returns a handler that format using conform plugin
--- @param pre_logic function|nil function to execute before formatting
--- @param post_logic function|nil function to execute after formatting
function L.conform_format_handler(pre_logic, post_logic)
	-- Returns a handler that format using the given lsp
	return function(args)
		if pre_logic then
			pre_logic()
		end
		local range = nil
		if args and args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({ async = true, lsp_format = "fallback", range = range })
		if post_logic then
			post_logic()
		end
	end
end

return L
