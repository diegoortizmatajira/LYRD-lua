local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")
local generator = require("LYRD.layers.lang.go-generator")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.layer.lang.Go: LYRD.setup.Module
local L = { name = "Go language" }

local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

--  run :GoBuild or :GoTestCompile based on the go file
local function build_go_files()
	local file = vim.fn.expand("%")
	if ends_with(file, "_test.go") then
		vim.fn["go#test#Test"](0, 1)
	else
		vim.fn["go#cmd#Build"](0)
	end
end
function L.plugins()
	setup.plugin({
		{
			"ray-x/go.nvim",
			dependencies = { -- optional packages
				"ray-x/guihua.lua",
				"neovim/nvim-lspconfig",
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {
				diagnostic = {
					virtual_text = false,
				},
			},
			ft = { "go", "gomod" },
			build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
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
	})
end

function L.preparation()
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
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"go",
		"gomod",
		"gosum",
		"gotmpl",
		"gowork",
	})

	local null_ls = require("null-ls")
	lsp.null_ls_register_sources({
		null_ls.builtins.code_actions.gomodifytags,
		null_ls.builtins.code_actions.impl,
	})
	lsp.format_with_conform("go", { "gofumpt", "goimports" })
	local test = require("LYRD.layers.test")
	test.configure_adapter(require("neotest-golang"))
end

-- This function to detect go html templates in html files
local function DetectGoHtmlTmpl()
	if vim.fn.expand("%:e") == "html" and vim.fn.search("{{") ~= 0 then
		vim.bo.filetype = "gohtmltmpl"
	end
end

function L.settings()
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
		{ cmd.LYRDCodeProduceGetter, generator.generate_getters },
		{ cmd.LYRDCodeProduceSetter, generator.generate_setters },
		{ cmd.LYRDCodeProduceMapping, generator.generate_mapping },
	})

	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		pattern = { "*.go" },
		command = "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4",
	})
	-- This auto command to detect go html templates for HUGO
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = "*.html",
		callback = DetectGoHtmlTmpl,
	})
end

function L.complete()
	vim.lsp.enable("gopls")
end

return L
