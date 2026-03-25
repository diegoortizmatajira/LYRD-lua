local commands = require("LYRD.layers.commands")
local c = commands.command_shortcut
local cmd = require("LYRD.layers.lyrd-commands").cmd
local icons = require("LYRD.layers.icons")

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @param key_table table
--- @param replacement_pairs  {[1]: string, [2]:string}[] contains pairs of (original_key, new_key) for keybinding replacements
local function replace_keybindings(key_table, replacement_pairs)
	for _, replacement in ipairs(replacement_pairs) do
		local original_key, new_key = unpack(replacement)
		for index, value in ipairs(key_table) do
			if value[2] == original_key then
				key_table[index][2] = new_key
				break
			end
		end
	end
end

--- Returns the current git branch name, or nil if not in a git repository.
--- @return string|nil
local function current_branch()
	local head = vim.trim(vim.fn.system("git branch --show-current"))
	if vim.v.shell_error ~= 0 or head == "" then
		return nil
	end
	return head
end

--- @type table|LYRD.setup.DeclarativeLayer
local L = {
	name = "Git",
	required_plugins = {
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
						["<cr>"] = "Toggle",
						["g"] = "GoToFile",
						["<tab>"] = false,
						["<c-s>"] = false,
						["<c-a>"] = "StageAll",
					},
					commit_editor = {
						["<c-s>"] = "Submit",
					},
					commit_editor_I = {
						["<c-s>"] = "Submit",
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
			config = function(_, opts)
				local utils = require("diffview.utils")
				local diff_config = require("diffview.config")
				-- Clones the default keymaps and replaces the default mappings with the custom mappings
				local custom_keymaps = utils.tbl_clone(diff_config.defaults.keymaps)
				custom_keymaps.disable_defaults = true
				replace_keybindings(custom_keymaps.view, {
					{ "<leader>co", "co" },
					{ "<leader>ct", "ct" },
					{ "<leader>cb", "cb" },
					{ "<leader>ca", "ca" },
					{ "<leader>cO", "cO" },
					{ "<leader>cT", "cT" },
					{ "<leader>cB", "cB" },
					{ "<leader>cA", "cA" },
				})
				replace_keybindings(custom_keymaps.file_panel, {
					{ "<leader>cO", "cO" },
					{ "<leader>cT", "cT" },
					{ "<leader>cB", "cB" },
					{ "<leader>cA", "cA" },
				})
				table.insert(custom_keymaps.file_panel, { "n", "q", c("DiffviewClose"), { desc = "Close the panel" } })
				opts.keymaps = custom_keymaps
				require("diffview").setup(opts)
			end,
		},
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
		{
			"FabijanZulj/blame.nvim",
			cmd = { "BlameToggle" },
			opts = {},
		},
		{
			"pwntester/octo.nvim",
			cmd = "Octo",
			opts = {
				picker = "telescope",
				enable_builtin = true,
			},
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
				"nvim-tree/nvim-web-devicons",
			},
		},
	},
	required_treesitter_parsers = {
		"git_config",
		"git_rebase",
		"gitattributes",
		"gitcommit",
		"gitignore",
	},
	required_executables = {
		"git",
		"lazygit",
		"tig",
	},
}

function L.git_flow_init()
	return function()
		vim.cmd(":!git flow init -d")
	end
end

function L.git_flow_start(what)
	return function()
		vim.ui.input({ prompt = "Name for the new branch: " }, function(name)
			if not name then
				return
			end
			vim.cmd(":!git flow " .. what .. " start " .. vim.fn.shellescape(name))
		end)
	end
end

function L.git_flow_finish(what)
	return function()
		local head = current_branch()
		if not head then
			return
		end
		local parts = vim.fn.split(head, "/")
		local name = parts[#parts]
		vim.cmd(string.format("!git flow %s finish %s", what, vim.fn.shellescape(name)))
	end
end

function L.git_flow_publish(what)
	return function()
		local head = current_branch()
		if not head then
			return
		end
		local target_branch = what == "feature" and "develop" or "main"
		local parts = vim.fn.split(head, "/")
		local name = parts[#parts]
		local ui = require("LYRD.layers.lyrd-ui")
		ui.toggle_external_app_terminal(
			string.format(
				[[gh pr create --base %s --head %s/%s --assignee "@me" --draft ]],
				target_branch,
				what,
				vim.fn.shellescape(name)
			)
		)
	end
end

function L.git_view_graph()
	return function()
		local ui = require("LYRD.layers.lyrd-ui")
		ui.toggle_external_app_terminal("tig")
	end
end

function L.settings()
	commands.implement({ "DiffviewFileHistory", "DiffviewFiles" }, {
		{ cmd.LYRDBufferClose, ":DiffviewClose" },
	})
	commands.implement("*", {
		{ cmd.LYRDGitUI, ":LazyGit" },
		{ cmd.LYRDGitStatus, ":Neogit" },
		{ cmd.LYRDGitCommit, require("neogit").action("commit", "commit", {}) },
		{ cmd.LYRDGitPush, require("neogit").action("push", "to_pushremote") },
		{ cmd.LYRDGitPull, require("neogit").action("pull", "from_pushremote") },
		{ cmd.LYRDGitViewDiff, ":DiffviewOpen -- %" },
		{ cmd.LYRDGitStageAll, ":!git add ." },
		{ cmd.LYRDGitViewCurrentFileLog, ":DiffviewFileHistory %" },
		{ cmd.LYRDGitFlowInit, L.git_flow_init() },
		{ cmd.LYRDGitFlowFeatureStart, L.git_flow_start("feature") },
		{ cmd.LYRDGitFlowFeatureFinish, L.git_flow_finish("feature") },
		{ cmd.LYRDGitFlowFeaturePublish, L.git_flow_publish("feature") },
		{ cmd.LYRDGitFlowReleaseStart, L.git_flow_start("release") },
		{ cmd.LYRDGitFlowReleaseFinish, L.git_flow_finish("release") },
		{ cmd.LYRDGitFlowReleasePublish, L.git_flow_publish("release") },
		{ cmd.LYRDGitFlowHotfixStart, L.git_flow_start("hotfix") },
		{ cmd.LYRDGitFlowHotfixFinish, L.git_flow_finish("hotfix") },
		{ cmd.LYRDGitFlowHotfixPublish, L.git_flow_publish("hotfix") },
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
		{ cmd.LYRDGitViewGraph, L.git_view_graph() },
		{ cmd.LYRDGitViewBlame, ":BlameToggle" },
		{ cmd.LYRDGitMergeConflicts, ":DiffviewOpen" },
		{ cmd.LYRDGithubIssueList, ":Octo issue list" },
		{ cmd.LYRDGithubIssueCreate, ":Octo issue create" },
		{ cmd.LYRDGithubIssueClose, ":Octo issue close" },
		{ cmd.LYRDGithubIssueReopen, ":Octo issue reopen" },
		{ cmd.LYRDGithubIssueDevelop, ":Octo issue develop" },
		{ cmd.LYRDGithubPullRequestList, ":Octo pr list" },
		{ cmd.LYRDGithubPullRequestCreate, ":Octo pr create" },
		{ cmd.LYRDGithubPullRequestClose, ":Octo pr close" },
		{ cmd.LYRDGithubPullRequestList, ":Octo pr list" },
	})
end

return declarative_layer.apply(L)
