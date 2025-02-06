local setup = require("LYRD.setup")
local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local L = { name = "Git" }

function L.plugins()
	setup.plugin({
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required
				"sindrets/diffview.nvim", -- optional - Diff integration
				"nvim-telescope/telescope.nvim", -- optional
			},
			opts = {
				kind = "split_below_all",
				disable_hint = false,
				disable_context_highlighting = true,
				graph_style = "unicode",
				signs = {
					-- { CLOSED, OPENED }
					hunk = { "", "" },
					item = { icons.chevron.right, icons.chevron.down },
					section = { icons.chevron.right, icons.chevron.down },
				},
				commit_editor = {
					kind = "floating",
					show_staged_diff = true,
					staged_diff_split_kind = "vsplit",
				},
				mappings = {
					status = {
						["<space>"] = "Toggle",
						["<tab>"] = false,
						["<c-s>"] = false,
						["<c-a>"] = "StageAll",
					},
				},
			},
		},
		{
			"sindrets/diffview.nvim", -- optional - Diff integration
			opts = {
				icons = { -- Only applies when use_icons is true.
					folder_closed = icons.folder.default,
					folder_open = icons.folder.open,
				},
				signs = {
					fold_closed = icons.chevron.right,
					fold_open = icons.chevron.down,
					done = icons.other.check,
				},
			},
		},
		-- {
		-- 	"tpope/vim-fugitive",
		-- },
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
			cmd = { "LazyGit" },
		},
		{
			"akinsho/git-conflict.nvim",
			version = "*",
			opts = {},
			event = "VeryLazy",
		},
		{
			"Juksuu/worktrees.nvim",
			opts = {},
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function(_, opts)
				require("worktrees").setup(opts)
				local telescope = require("telescope")
				telescope.load_extension("worktrees")
			end,
		},
	})
end

function L.git_flow_start(what)
	return function()
		vim.ui.input({ prompt = "Name for the new branch: " }, function(name)
			if not name then
				return
			end
			vim.cmd(":!git flow " .. what .. " start " .. name)
		end)
	end
end

function L.git_flow_finish(what)
	return function()
		local head = vim.fn.FugitiveHead()
		local name = vim.fn.split(head, "/")[#vim.fn.split(head, "/")]
		vim.cmd(string.format("!git flow %s finish %s", what, name))
	end
end

function L.settings()
	commands.implement({ "DiffviewFileHistory", "DiffviewFiles" }, {
		-- { cmd.LYRDBufferClose, ":DiffViewClose" },
		{ cmd.LYRDBufferClose, ":tabclose" },
	})
	commands.implement("*", {
		{ cmd.LYRDGitUI, ":LazyGit" },
		{ cmd.LYRDGitStatus, ":Neogit" },
		{ cmd.LYRDGitCommit, require("neogit").action("commit", "commit", {}) },
		{ cmd.LYRDGitPush, require("neogit").action("push", "to_pushremote") },
		{ cmd.LYRDGitPull, require("neogit").action("pull", "from_pushremote") },
		{ cmd.LYRDGitViewDiff, ":DiffviewOpen -- %" },
		{ cmd.LYRDGitStageAll, ":!git add ." },
		{ cmd.LYRDGitViewBlame, ":Git_blame" },
		{ cmd.LYRDGitViewCurrentFileLog, ":DiffviewFileHistory %" },
		{ cmd.LYRDGitBrowseOnWeb, ":GBrowse" },
		{ cmd.LYRDGitFlowInit, ":!git flow init -d" },
		{ cmd.LYRDGitFlowFeatureStart, L.git_flow_start("feature") },
		{ cmd.LYRDGitFlowFeatureFinish, L.git_flow_finish("feature") },
		{ cmd.LYRDGitFlowReleaseStart, L.git_flow_start("release") },
		{ cmd.LYRDGitFlowReleaseFinish, L.git_flow_finish("release") },
		{ cmd.LYRDGitFlowHotfixStart, L.git_flow_start("hotfix") },
		{ cmd.LYRDGitFlowHotfixFinish, L.git_flow_finish("hotfix") },
		{ cmd.LYRDGitCheckoutMain, ":!git checkout main" },
		{ cmd.LYRDGitCheckoutDev, ":!git checkout develop" },
		{
			cmd.LYRDGitWorkTreeList,
			function()
				require("telescope").extensions.worktrees.list_worktrees()
			end,
		},
		{ cmd.LYRDGitWorkTreeCreate, ":GitWorktreeCreate" },
		{ cmd.LYRDGitWorkTreeCreateExistingBranch, ":GitWorktreeCreateExisting" },
	})
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("git")
	health.check_executable("lazygit")
end

return L
