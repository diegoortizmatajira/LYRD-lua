local setup = require "setup"
local commands = require "layers.commands"

local L = {name = 'Git'}

function L.plugins(s) setup.plugin(s, {'tpope/vim-fugitive', 'airblade/vim-gitgutter', 'tpope/vim-dispatch'}) end

function L.git_flow_start(what)
    local name = vim.api.nvim_exec([[
        let newname = input('Name for the new branch: ')
        echo newname
    ]], true)
    vim.cmd(':Git flow ' .. what .. ' start ' .. name)
end

function L.git_flow_finish(what)
    local name = vim.api.nvim_exec([[
        let parts = split(FugitiveHead(),'/')
        echo parts[len(parts)-1]
    ]], true)
    vim.cmd(':Git flow ' .. what .. ' finish ' .. name)
end

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
        LYRDGitPull = ':Git pull',
        LYRDGitViewDiff = ':Gvdiffsplit',
        LYRDGitStageAll = ':Git add .',
        LYRDGitViewBlame = ':Git_blame',
        LYRDGitRemove = ':GRemove',
        LYRDGitViewCurrentFileLog = ':Gclog -- %',
        LYRDGitViewLog = ':Gclog --',
        LYRDGitBrowseOnWeb = ':Gbrowse',
        LYRDGitFlowInit = ':Git flow init',
        LYRDGitFlowFeatureStart = [[:lua require('layers.git').git_flow_start('feature')]],
        LYRDGitFlowFeatureFinish = [[:lua require('layers.git').git_flow_finish('feature')]],
        LYRDGitFlowReleaseStart = [[:lua require('layers.git').git_flow_start('release')]],
        LYRDGitFlowReleaseFinish = [[:lua require('layers.git').git_flow_finish('release')]],
        LYRDGitFlowHotfixStart = [[:lua require('layers.git').git_flow_start('hotfix')]],
        LYRDGitFlowHotfixFinish = [[:lua require('layers.git').git_flow_finish('hotfix')]],
        LYRDGitCheckoutMain = ':Git checkout main',
        LYRDGitCheckoutDev = ':Git checkout develop'
    })
end

function L.keybindings(s) end

function L.complete(s) end

return L
