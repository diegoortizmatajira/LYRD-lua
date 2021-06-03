local setup = require "setup"
local lsp = require "layers.lsp"

local L = {
    name = 'Go language'
}

function L.plugins(s)
    setup.plugin(s, {
        {  'fatih/vim-go', "{'do': ':GoUpdateBinaries'}"},
    })
end

function L.settings(_)
    lsp.enable('gopls', {})
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
end

function L.keybindings(s)
end

return L
