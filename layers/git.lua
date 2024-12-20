local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Git" }

function L.plugins(s)
	setup.plugin(s, {
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required
				"sindrets/diffview.nvim", -- optional - Diff integration

				-- Only one of these is needed.
				"nvim-telescope/telescope.nvim", -- optional
				"ibhagwan/fzf-lua", -- optional
				"echasnovski/mini.pick", -- optional
			},
			opts = {
				kind = "split_below_all",
				disable_hint = true,
				graph_style = "unicode",
				signs = {
					-- { CLOSED, OPENED }
					hunk = { "", "" },
					item = { icons.chevron.right, icons.chevron.down },
					section = { icons.chevron.right, icons.chevron.down },
				},
				commit_editor = {
					kind = "split_below_all",
					show_staged_diff = true,
					staged_diff_split_kind = "vsplit",
				},
			},
		},
		{
		    "tpope/vim-fugitive",
		},
		-- {
		--     "tpope/vim-rhubarb",
		--     dependencies = {
		--
		--         "tpope/vim-fugitive",
		--     },
		-- },
		-- {
		--     "tpope/vim-dispatch",
		-- },
		{
			"lewis6991/gitsigns.nvim",
			opts = {
				signs = {
					add = { text = icons.git_gutter.add },
					change = { text = icons.git_gutter.change },
					delete = { text = icons.git_gutter.delete },
					topdelete = { text = icons.git_gutter.topdelete },
					changedelete = { text = icons.git_gutter.changedelete },
					untracked = { text = icons.git_gutter.untracked },
				},
				signs_staged = {
					add = { text = icons.git_gutter.add },
					change = { text = icons.git_gutter.change },
					delete = { text = icons.git_gutter.delete },
					topdelete = { text = icons.git_gutter.topdelete },
					changedelete = { text = icons.git_gutter.changedelete },
					untracked = { text = icons.git_gutter.untracked },
				},
				signs_staged_enable = true,
				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				watch_gitdir = {
					interval = 1000,
					follow_files = true,
				},
				auto_attach = true,
				attach_to_untracked = false,
				current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
					delay = 1000,
					ignore_whitespace = false,
				},
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
				sign_priority = 6,
				status_formatter = nil, -- Use default
				update_debounce = 200,
				max_file_length = 40000,
				preview_config = {
					-- Options passed to nvim_open_win
					border = "rounded",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
			},
		},
		{
			"kdheepak/lazygit.nvim",
			-- optional for floating window border decoration
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
		{
			"akinsho/git-conflict.nvim",
			version = "*",
			opts = {},
		},
		{
			"isak102/telescope-git-file-history.nvim",
			opts = {},
			config = function(_, opts)
				require("telescope").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("git_file_history")
			end,
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
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
	commands.implement(s, "*", {
		{ cmd.LYRDGitUI, ":LazyGit" },
		{ cmd.LYRDGitStatus, ":Neogit" },
		{ cmd.LYRDGitCommit, ":Neogit commit" },
		{ cmd.LYRDGitPush, ":Neogit push" },
		{ cmd.LYRDGitPull, ":Neogit pull" },
		{ cmd.LYRDGitViewDiff, ":Gvdiffsplit" },
		{ cmd.LYRDGitStageAll, ":Git add ." },
		{ cmd.LYRDGitViewBlame, ":Git_blame" },
		{ cmd.LYRDGitViewCurrentFileLog, ":Telescope git_file_history" },
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
