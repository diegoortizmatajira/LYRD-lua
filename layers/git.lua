local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

local L = { name = "Git" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"tpope/vim-fugitive",
			cmd = {
				"Git",
				"Gwrite",
				"Gread",
				"Ggrep",
				"GDelete",
				"GMove",
				"Gvdiffsplit",
				"Gdiffsplit",
				"GBrowse",
			},
		},
		{
			"tpope/vim-rhubarb",
			dependencies = {

				"tpope/vim-fugitive",
			},
		},
		"tpope/vim-dispatch",
		{ "lewis6991/gitsigns.nvim" },
		{
			"kdheepak/lazygit.nvim",
			lazy = true,
			cmd = {
				"LazyGit",
				"LazyGitConfig",
				"LazyGitCurrentFile",
				"LazyGitFilter",
				"LazyGitFilterCurrentFile",
			},
			-- optional for floating window border decoration
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
	})
end

function L.git_flow_start(what)
	vim.ui.input({ prompt = "Name for the new branch: " }, function(name)
		if not name then
			return
		end
		vim.cmd(":Git flow " .. what .. " start " .. name)
	end)
end

function L.git_flow_finish(what)
	local name = vim.api.nvim_exec2(
		[[
    let parts = split(FugitiveHead(),'/')
    echo parts[len(parts)-1]
        ]],
		{ capture_output = true }
	)
	vim.cmd(":Git flow " .. what .. " finish " .. name)
end

function L.settings(s)
	commands.implement(s, "fugitive", {
		{ cmd.LYRDBufferSave, [[:echo 'No saving']] },
	})
	commands.implement(s, "*", {
		{ cmd.LYRDGitUI, ":LazyGit" },
		{ cmd.LYRDGitStatus, ":Git" },
		{ cmd.LYRDGitCommit, ":Git commit" },
		{ cmd.LYRDGitPush, ":Git push" },
		{ cmd.LYRDGitPull, ":Git pull" },
		{ cmd.LYRDGitViewDiff, ":Gvdiffsplit" },
		{ cmd.LYRDGitStageAll, ":Git add ." },
		{ cmd.LYRDGitViewBlame, ":Git_blame" },
		{ cmd.LYRDGitViewCurrentFileLog, ":LazyGitFilterCurrentFile" },
		{ cmd.LYRDGitBrowseOnWeb, ":GBrowse" },
		{ cmd.LYRDGitFlowInit, ":Git flow init" },
		{
			cmd.LYRDGitFlowFeatureStart,
			function()
				L.git_flow_start("feature")
			end,
		},
		{
			cmd.LYRDGitFlowFeatureFinish,
			function()
				L.git_flow_finish("feature")
			end,
		},
		{
			cmd.LYRDGitFlowReleaseStart,
			function()
				L.git_flow_start("release")
			end,
		},
		{
			cmd.LYRDGitFlowReleaseFinish,
			function()
				L.git_flow_finish("release")
			end,
		},
		{
			cmd.LYRDGitFlowHotfixStart,
			function()
				L.git_flow_start("hotfix")
			end,
		},
		{
			cmd.LYRDGitFlowHotfixFinish,
			function()
				L.git_flow_finish("hotfix")
			end,
		},
		{ cmd.LYRDGitCheckoutMain, ":Git checkout main" },
		{ cmd.LYRDGitCheckoutDev, ":Git checkout develop" },
	})
end

return L
