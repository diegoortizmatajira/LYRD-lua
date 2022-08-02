local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"
local mappings = require"LYRD.layers.mappings"
local lsp = require"LYRD.layers.lsp"
local c = commands.command_shortcut

local L = {name = 'Go language'}

function L.plugins(s)
  setup.plugin(s, {{'fatih/vim-go', run = ':GoUpdateBinaries'}, 'leoluz/nvim-dap-go'})
end

function L.settings(s)
  commands.implement(s, 'go', {
    LYRDCodeBuild = ':lua require("LYRD.layers.lang.go").build_go_files()',
    LYRDCodeRun = ':GoRun',
    LYRDTest = ':GoTest',
    LYRDTestCoverage = ":GoCoverageToggle",
    LYRDCodeAlternateFile = ":GoAlternate",
    LYRDBufferFormat = ":GoFmt",
    LYRDCodeFixImports = ":GoImports",
    LYRDCodeGlobalCheck = ":GoMetaLinter!",
    LYRDCodeImplementInterface = "GoImpl",
    LYRDCodeFillStructure = ':GoFillStruct',
    LYRDCodeGenerate = ':GoGenerate'

  })
  vim.g.go_list_type = "quickfix"
  vim.g.go_fmt_command = "goimports"
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
  vim.g.go_debug_breakpoint_sign_text = '>'

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

  require('dap-go').setup()
end

function L.keybindings(s)
  mappings.space_menu(s, {{{'p', 'g'}, 'Golang'}})
  mappings.space(s,
    {{'n', {'p', 'g', 'g'}, ':lua require("LYRD.layers.lang.go").generate_getters()', 'Generate Getters'}})
  mappings.space(s,
    {{'n', {'p', 'g', 's'}, ':lua require("LYRD.layers.lang.go").generate_setters()', 'Generate Setters'}})
  mappings.space(s,
    {{'n', {'p', 'g', 'm'}, ':lua require("LYRD.layers.lang.go").generate_mapping()', 'Generate Mapping'}})
end

function L.complete(_)
  lsp.enable('gopls', {})
end

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

--  run :GoBuild or :GoTestCompile based on the go file
function L.build_go_files()
  local file = vim.fn.expand('%')
  if ends_with(file, "_test.go") then
    vim.fn["go#test#Test"](0, 1)
  else
    vim.fn["go#cmd#Build"](0)
  end
end

function L.generate_getters()
  local receiver = vim.api.nvim_exec([[
    let newname = input('Name for the receiver: ')
    echo newname
        ]], true)
  local receiver_type = vim.api.nvim_exec([[
    let newname = input('Name for the receiver type: ')
    echo newname
        ]], true)
  vim.cmd(c(string.format([['<,'>s/\(\w\+\)\s\+\([a-zA-Z.0-9]\+\)/func (%s %s) \u\1() \2 { return %s.\1 }/g]], receiver,
    receiver_type, receiver)))
  vim.cmd('noh')
end

function L.generate_setters()
  local receiver = vim.api.nvim_exec([[
    let newname = input('Name for the receiver: ')
    echo newname
        ]], true)
  local receiver_type = vim.api.nvim_exec([[
    let newname = input('Name for the receiver type: ')
    echo newname
        ]], true)
  vim.cmd(c(string.format([['<,'>s/\(\w\+\)\s\+\([a-zA-Z.0-9]\+\)/func (%s %s) Set\u\1(value \2) { %s.\1 = value }/g]],
    receiver, receiver_type, receiver)))
  vim.cmd('noh')
end

function L.generate_mapping()
  local receiver = vim.api.nvim_exec([[
    let newname = input('Name for the target prefix: ')
    echo newname
        ]], true)
  if receiver ~= '' then receiver = receiver .. '.' end
  local source_prefix = vim.api.nvim_exec([[
    let newname = input('Name for the source prefix (or empty if not required): ')
    echo newname
        ]], true)
  if source_prefix ~= '' then source_prefix = source_prefix .. '.' end
  local operator = vim.api.nvim_exec([[
    let newname = input('Operator sign: ')
    echo newname
        ]], true)
  vim.cmd(string.format([[:'<,'>s/\(\w\+\)\s\+\([a-zA-Z.0-9]\+\)/ %s\1 %s %s\1/g]], receiver, operator, source_prefix))
  vim.cmd('noh')
end

return L
