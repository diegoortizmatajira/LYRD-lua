local setup = require"LYRD.setup"
local commands = require"LYRD.layers.commands"
local mappings = require"LYRD.layers.mappings"
local lsp = require"LYRD.layers.lsp"
local dap = require('dap')
local c = commands.command_shortcut

local L = {name = 'C# language'}

function L.plugins(s)
  setup.plugin(s, {
    {'OmniSharp/omnisharp-vim', requires = {'tpope/vim-dispatch'}},
    'nickspoons/vim-sharpenup',
    'adamclerk/vim-razor'
  })

end

function L.settings(s)
  commands.implement(s, 'cs', {
    LYRDTest = ':OmniSharpRunTestsInFile',
    LYRDTestSuite = ':OmniSharpRunTestsInFile',
    LYRDTestFile = ':OmniSharpRunTestsInFile',
    LYRDTestFunc = ':OmniSharpRunTest',
    LYRDTestLast = ':OmniSharpRunTestsInFile',
    LYRDViewDocumentation = ':OmniSharpDocumentation',
    LYRDFixImports = ':OmniSharpFixUsings',
    LYRDCodeGlobalCheck = ':OmniSharpGlobalCodeCheck',
    LYRDBufferFormat = ':OmniSharpCodeFormat'
  })
  dap.adapters.coreclr = {
    type = 'executable',
    command = '/path/to/dotnet/netcoredbg/netcoredbg',
    args = {'--interpreter=vscode'}
  }
  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "launch - netcoredbg",
      request = "launch",
      program = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
      end
    }
  }
end

function L.keybindings(s)
  mappings.space_menu(s, {{{'p', 'o'}, 'OmniSharp'}})
  mappings.space(s, {
    {'n', {'p', 'o', 'l'}, c('OmniSharpOpenLog'), 'Open log'},
    {'n', {'p', 'o', 'r'}, c('OmniSharpRestartServer'), 'Restart OmniSharp server'},
    {'n', {'p', 'o', 'S'}, c('OmniSharpStatus'), 'OmniSharp status'},
    {'n', {'p', 'o', 's'}, c('OmniSharpStartServer'), 'Start OmniSharp server'},
    {'n', {'p', 'o', 'x'}, c('OmniSharpStopServer'), 'Stop OmniSharp server'},
    {'n', {'p', 'o', 'i'}, c('OmniSharpInstall'), 'Install OmniSharp'}
  })
end

function L.complete(_)
  vim.g.OmniSharp_server_use_net6 = 1
  local pid = vim.fn.getpid()
  local omnisharp_bin = vim.fn.expand("~/.cache/omnisharp-vim/omnisharp-roslyn/OmniSharp")
  lsp.enable('omnisharp', {cmd = {omnisharp_bin, "--languageserver", "--hostPID", tostring(pid)}})
end

return L
