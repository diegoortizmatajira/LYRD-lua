local generator = require("LYRD.layers.lang.go-generator")
local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Go language",
	required_plugins = {
		{
			"ray-x/go.nvim",
			opts = {
				diagnostic = {
					virtual_text = false,
				},
			},
			ft = { "go", "gomod" },
			-- If you need to install/update all binaries
			build = ':lua require("go.install").update_all_sync()',
		},
		{
			"leoluz/nvim-dap-go",
			ft = "go", -- only load on go files
			opts = {},
		},
		{
			"fredrikaverpil/neotest-golang",
			ft = "go",
		},
		-- lazy.nvim --
		{
			"ngynkvn/gotmpl.nvim",
			opts = {},
		},
	},
	required_mason_packages = {
		"delve",
		"go-debug-adapter",
		"gofumpt",
		"goimports",
		"golangci-lint",
		"golangci-lint-langserver",
		"golines",
		"gomodifytags",
		"gopls",
		"gotests",
		"impl",
	},
	required_treesitter_parsers = {
		"go",
		"gomod",
		"gosum",
		"gotmpl",
		"gowork",
	},
	required_enabled_lsp_servers = {
		"gopls",
		"golangci_lint_ls",
	},
	required_formatter_per_filetype = {
		{
			target_filetype = { "go" },
			format_settings = { "gofumpt", "goimports" },
		},
	},
	required_test_adapters = {
		"neotest-golang",
	},
	required_null_ls_sources = {
		"null-ls.builtins.code_actions.gomodifytags",
		"null-ls.builtins.code_actions.impl",
	},
}

local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

local function build_go_files()
	local file = vim.fn.expand("%")
	if ends_with(file, "_test.go") then
		vim.fn["go#test#Test"](0, 1)
	else
		vim.fn["go#cmd#Build"](0)
	end
end

-- This function to detect go HTML templates in HTML files
local function DetectGoHtmlTmpl()
	if vim.fn.expand("%:e") == "html" and vim.fn.search("{{") ~= 0 then
		vim.bo.filetype = "gohtmltmpl"
	end
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	local wrap = commands.wrap
	commands.implement("go", {
		{ cmd.LYRDCodeBuild, build_go_files },
		{ cmd.LYRDCodeRun, ":GoRun" },
		{ cmd.LYRDTest, ":GoTest" },
		{ cmd.LYRDTestCoverage, ":GoCoverageToggle" },
		{ cmd.LYRDCodeAlternateFile, ":GoAlternate" },
		{ cmd.LYRDBufferFormat, ":GoFmt" },
		{ cmd.LYRDCodeFixImports, ":GoImports" },
		{ cmd.LYRDCodeGlobalCheck, ":GoMetaLinter!" },
		{ cmd.LYRDCodeImplementInterface, "GoImpl" },
		{ cmd.LYRDCodeFillStructure, ":GoFillStruct" },
		{ cmd.LYRDCodeGenerate, ":GoGenerate" },
		{ cmd.LYRDCodeProduceGetter, wrap(generator.generate_getters) },
		{ cmd.LYRDCodeProduceSetter, wrap(generator.generate_setters) },
		{ cmd.LYRDCodeProduceMapping, wrap(generator.generate_mapping) },
	})

	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		pattern = { "*.go" },
		command = "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4",
	})
	-- This auto command to detect go HTML templates for Hugo
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = "*.html",
		callback = DetectGoHtmlTmpl,
	})
end

return declarative_layer.apply(L)
