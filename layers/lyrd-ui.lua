local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"

local L = {name = 'LYRD UI'}

function L.plugins(s)
  setup.plugin(s, {
    {'nvim-lualine/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}},
    {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'},
    'ellisonleao/gruvbox.nvim',
    -- 'gruvbox-community/gruvbox',
    'mhinz/vim-startify',
    'junegunn/vim-peekaboo',
    'lukas-reineke/indent-blankline.nvim',
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
  require('lualine').setup({options = {theme = 'gruvbox'}})
  require("bufferline").setup({options = {diagnostics = 'nvim_lsp'}})
  -- airline_setup()
  devicons_setup()
  -- Highlight the yanked text
  vim.cmd([[
    augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=500}
    augroup END
    ]])
  commands.implement(s, '*', {
    LYRDViewHomePage = ':Startify',
    LYRDBufferNext = ':BufferLineCycleNext',
    LYRDBufferPrev = ':BufferLineCyclePrev'
  })
end

return L
