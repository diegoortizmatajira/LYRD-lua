local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"

local L = {name = 'LYRD UI'}

function L.plugins(s)
  setup.plugin(s, {
    'vim-airline/vim-airline',
    'vim-airline/vim-airline-themes',
    'gruvbox-community/gruvbox',
    'mhinz/vim-startify',
    'junegunn/vim-peekaboo',
    'kyazdani42/nvim-web-devicons'
  })
end

local function startify_setup()
  -- Startify settings

  vim.g.startify_session_dir = '~/.config/nvim/session'
  vim.g.startify_lists = {
    {type = 'sessions', header = {'   Sessions'}},
    {type = 'dir', header = {'   Current Directory '}},
    {type = 'files', header = {'   Files'}},
    {type = 'bookmarks', header = {'   Bookmarks'}}
  }
  vim.g.startify_session_autoload = 1
  vim.g.startify_session_delete_buffers = 1
  vim.g.startify_custom_header = {
    [[   ___       __    ______                            ]],
    [[   __ |     / /_______  /__________________ ________ ]],
    [[   __ | /| / /_  _ \_  /_  ___/  __ \_  __ `__ \  _ \]],
    [[   __ |/ |/ / /  __/  / / /__ / /_/ /  / / / / /  __/]],
    [[   ____/|__/  \___//_/  \___/ \____//_/ /_/ /_/\___/ ]]
  }
  vim.g.startify_change_to_dir = 0
  vim.g.startify_change_to_vcs_root = 0
end

local function airline_setup()
  -- vim-airline
  vim.g['airline#extensions#branch#enabled'] = 1
  vim.g['airline#extensions#ale#enabled'] = 1
  vim.g['airline#extensions#tabline#enabled'] = 1
  vim.g['airline#extensions#tagbar#enabled'] = 1
  vim.g['airline_skip_empty_sections'] = 1

  -- vim-airline
  vim.g.airline_symbols = {linenr = '␊', branch = '⎇', paste = 'ρ', whitespace = 'Ξ'}

  vim.g['airline#extensions#tabline#left_sep'] = ''
  vim.g['airline#extensions#tabline#left_alt_sep'] = '|'
  vim.g.airline_left_sep = ''
  vim.g.airline_left_alt_sep = '»'
  vim.g.airline_right_sep = ''
  vim.g.airline_right_alt_sep = '«'
  vim.g['airline#extensions#branch#prefix'] = '⤴'
  vim.g['airline#extensions#readonly#symbol'] = '⊘'
  vim.g['airline#extensions#linecolumn#prefix'] = '¶'
  vim.g['airline#extensions#paste#symbol'] = 'ρ'
end

local function devicons_setup()
  vim.g.webdevicons_enable = 1
  vim.g.webdevicons_enable_nerdtree = 1
  vim.g.webdevicons_enable_unite = 1
  vim.g.webdevicons_enable_vimfiler = 1
  vim.g.webdevicons_enable_airline_tabline = 1
  vim.g.webdevicons_enable_airline_statusline = 1
  vim.g.webdevicons_enable_ctrlp = 1
  vim.g.webdevicons_enable_flagship_statusline = 1
  vim.g.WebDevIconsUnicodeDecorateFileNodes = 1
  vim.g.WebDevIconsUnicodeGlyphDoubleWidth = 1
  vim.g.webdevicons_conceal_nerdtree_brackets = 1
  vim.g.WebDevIconsNerdTreeAfterGlyphPadding = '  '
  vim.g.WebDevIconsNerdTreeGitPluginForceVAlign = 1
  vim.g.webdevicons_enable_denite = 1
  vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1
  vim.g.DevIconsEnableFoldersOpenClose = 1
  vim.g.DevIconsEnableFolderPatternMatching = 1
  vim.g.DevIconsEnableFolderExtensionPatternMatching = 1
  vim.g.WebDevIconsUnicodeDecorateFolderNodesExactMatches = 1
end

function L.settings(s)
  vim.cmd([[colorscheme gruvbox]])
  startify_setup()
  airline_setup()
  devicons_setup()
  -- Highlight the yanked text
  vim.cmd([[
    augroup highlight_yank
        autocmd!
        au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=500}
    augroup END
    ]])
  commands.implement(s, '*', {LYRDViewHomePage = ':Startify'})
end

return L
