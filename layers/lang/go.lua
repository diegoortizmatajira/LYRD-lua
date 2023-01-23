local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local lsp = require("LYRD.layers.lsp")

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
		LYRDCodeProduceGetter = L.generate_getters,
		LYRDCodeProduceSetter = L.generate_setters,
		LYRDCodeProduceMapping = L.generate_mapping,
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

	require("dap-go").setup()
end

function L.complete(_)
	lsp.enable("gopls", { settings = { gopls = { gofumpt = true, buildFlags = { "-tags=wireinject,integration" } } } })
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

local function get_root(bufnr)
	local parser = vim.treesitter.get_parser(bufnr, "go", {})
	local tree = parser:parse()[1]
	return tree:root()
end

local function process_fields_from_struct(bufnr, string_generator)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype ~= "go" then
		vim.notify("Can only be used in Golang")
		return
	end
	local fields = vim.treesitter.parse_query(
		"go",
		[[
(type_spec .
    (type_identifier) @struct_name
    (struct_type
        (field_declaration_list
            (field_declaration
                name: (field_identifier) @field_name
                type: (_) @type_identifier
            )
        )
    )
)
        ]]
	)
	local root = get_root(bufnr)
	local new_lines = { "" }
	for _, captures, _ in fields:iter_matches(root, bufnr) do
		local struct_name = vim.treesitter.query.get_node_text(captures[1], bufnr)
		local field_name = vim.treesitter.query.get_node_text(captures[2], bufnr)
		local field_type = vim.treesitter.query.get_node_text(captures[3], bufnr)
		local text = string_generator(struct_name, field_name, field_type)
		table.insert(new_lines, text)
	end
	table.insert(new_lines, "")
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(bufnr, row, row, false, new_lines)
end

function L.generate_getters(bufnr)
	process_fields_from_struct(bufnr, function(struct_name, field_name, field_type)
		local receiver = string.lower(string.sub(struct_name, 1, 1))
		local getter_name = (field_name:gsub("^%l", string.upper))
		return string.format(
			[[func (%s %s) %s() %s { return %s.%s}]],
			receiver,
			struct_name,
			getter_name,
			field_type,
			receiver,
			field_name
		)
	end)
end

function L.generate_setters(bufnr)
	process_fields_from_struct(bufnr, function(struct_name, field_name, field_type)
		local receiver = string.lower(string.sub(struct_name, 1, 1))
		local property_name = (field_name:gsub("^%l", string.upper))
		return string.format(
			[[func (%s %s) Set%s(value %s) { %s.%s = value }]],
			receiver,
			struct_name,
			property_name,
			field_type,
			receiver,
			field_name
		)
	end)
end

function L.generate_mapping(bufnr)
	local target_prefix = vim.fn.input("Name for the target prefix (or empty if not required): ")
	if target_prefix ~= "" then
		target_prefix = target_prefix .. "."
	end
	local source_prefix = vim.fn.input("Name for the source prefix (or empty if not required): ")
	if source_prefix ~= "" then
		source_prefix = source_prefix .. "."
	end
	local operator = vim.fn.input("Operator sign: ")
	process_fields_from_struct(bufnr, function(_, field_name, _)
		return string.format([[%s%s %s %s%s]], target_prefix, field_name, operator, source_prefix, field_name)
	end)
end

return L
