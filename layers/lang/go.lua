local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")
local generator = require("LYRD.layers.lang.go-generator")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Go language" }

function L.plugins(s)
	setup.plugin(s, {
		{ "fatih/vim-go", run = ":GoUpdateBinaries" },
		"leoluz/nvim-dap-go",
		"nvim-neotest/neotest-go",
	})
end

function L.settings(s)
	commands.implement(s, "go", {
		{ cmd.LYRDCodeBuild, L.build_go_files },
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
		{ cmd.LYRDCodeProduceGetter, generator.generate_getters },
		{ cmd.LYRDCodeProduceSetter, generator.generate_setters },
		{ cmd.LYRDCodeProduceMapping, generator.generate_mapping },
	})
	vim.g.go_list_type = "quickfix"
	vim.g.go_fmt_command = "gopls"
	vim.g.go_gopls_gofumpt = 1
	vim.g.go_fmt_fail_silently = 1
	vim.g.go_def_mapping_enabled = 0
	vim.g.go_doc_popup_window = 1
	vim.g.go_highlight_types = 1
	vim.g.go_highlight_fields = 1
	vim.g.go_highlight_functions = 1
	vim.g.go_highlight_methods = 1
	vim.g.go_highlight_operators = 1
	vim.g.go_highlight_build_constraints = 1
	vim.g.go_highlight_structs = 1
	vim.g.go_highlight_generate_tags = 1
	vim.g.go_highlight_space_tab_error = 0
	vim.g.go_highlight_array_whitespace_error = 0
	vim.g.go_highlight_trailing_whitespace_error = 0
	vim.g.go_highlight_extra_types = 1
	vim.g.go_debug_breakpoint_sign_text = ">"

	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		pattern = { "*.go" },
		command = "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4",
	})

	lsp.mason_ensure({
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
	})

	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.formatting.gofumpt,
	})
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-go"))
end

function L.complete(_)
	lsp.enable("gopls", {
		settings = {
			gopls = {
				gofumpt = true,
				buildFlags = { "-tags=wireinject,integration" },
			},
		},
	})
	require("dap-go").setup()
end

local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

--  run :GoBuild or :GoTestCompile based on the go file
function L.build_go_files()
	local file = vim.fn.expand("%")
	if ends_with(file, "_test.go") then
		vim.fn["go#test#Test"](0, 1)
	else
		vim.fn["go#cmd#Build"](0)
	end
end

return L
