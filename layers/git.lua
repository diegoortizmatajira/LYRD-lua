local setup = require "setup"
local commands = require "layers.commands"

local L = {name = 'Git'}

function L.plugins(s) setup.plugin(s, {'tpope/vim-fugitive', 'airblade/vim-gitgutter', 'tpope/vim-dispatch'}) end

function L.settings(s)
    vim.g.gitgutter_map_keys = 0
    commands.implement(s, '*', {
        LYRDGitModifiedFiles = ':Git',
        LYRDGitBranches = ':Git branch',
        LYRDGitCommits = '',
        LYRDGitBufferCommits = '',
        LYRDGitStash = '',
        LYRDGitStatus = ':Git',
        LYRDGitStageCurrentFile = ':Git add %',
        LYRDGitUnstageCurrentFile = ':Git reset -q %',
        LYRDGitCommit = ':Git commit',
        LYRDGitWrite = ':Gwrite',
        LYRDGitPush = ':Git push',
        LYRDGitPull = ':Git pull"',
        LYRDGitViewDiff = ':Gvdiffsplit',
        LYRDGitStageAll = ':Git add .',
        LYRDGitViewBlame = ':Git_blame',
        LYRDGitRemove = ':GRemove',
        LYRDGitViewCurrentFileLog = ':Gclog -- %',
        LYRDGitViewLog = ':Gclog --',
        LYRDGitBrowseOnWeb = ':Gbrowse',
        LYRDGitFlowInit = ':Git flow init',
        LYRDGitFlowFeatureStart = ':Git flow feature start',
        LYRDGitFlowFeatureFinish = ':Git flow feature finish',
        LYRDGitFlowReleaseStart = ':Git flow release start',
        LYRDGitFlowReleaseFinish = ':Git flow release finish',
        LYRDGitFlowHotfixStart = ':Git flow hotfix start',
        LYRDGitFlowHotfixFinish = ':Git flow hotfix finish',
        LYRDGitCheckoutMain = ':Git checkout main',
        LYRDGitCheckoutDev = ':Git checkout develop'
    })
end

function L.keybindings(s) end

function L.complete(s) end

return L
