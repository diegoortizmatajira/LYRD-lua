local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")
local generator = require("LYRD.layers.lang.go-generator")

local L = { name = "Go language" }

function L.plugins(s)
	setup.plugin(s, { { "fatih/vim-go", run = ":GoUpdateBinaries" }, "leoluz/nvim-dap-go" })
end

function L.settings(s)
	commands.implement(s, "go", {
		LYRDCodeBuild = L.build_go_files,
		LYRDCodeRun = ":GoRun",
		LYRDTest = ":GoTest",
		LYRDTestCoverage = ":GoCoverageToggle",
		LYRDCodeAlternateFile = ":GoAlternate",
		LYRDBufferFormat = ":GoFmt",
		LYRDCodeFixImports = ":GoImports",
		LYRDCodeGlobalCheck = ":GoMetaLinter!",
		LYRDCodeImplementInterface = "GoImpl",
		LYRDCodeFillStructure = ":GoFillStruct",
		LYRDCodeGenerate = ":GoGenerate",
		LYRDCodeProduceGetter = generator.generate_getters,
		LYRDCodeProduceSetter = generator.generate_setters,
		LYRDCodeProduceMapping = generator.generate_mapping,
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

	vim.cmd([[
    autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
    ]])
	vim.cmd([[
    augroup completion_preview_close
    autocmd!
    if v:version > 703 || v:version == 703 && has('patch598')
    autocmd CompleteDone * if !&previewwindow && &completeopt =~ 'preview' | silent! pclose | endif
    endif
    augroup END
    ]])

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

end

function L.complete(_)
	lsp.enable("gopls", { settings = { gopls = { gofumpt = true, buildFlags = { "-tags=wireinject,integration" } } } })
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
