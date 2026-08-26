local tasks = require("LYRD.layers.tasks")

local CONFIG_MARKERS = {
	"hugo.toml",
	"hugo.yaml",
	"hugo.yml",
	"hugo.json",
	"config.toml",
	"config.yaml",
	"config.yml",
	"config.json",
}

local DEFAULT_SECTION = "posts"
local DEFAULT_EXTENSION = ".md"

local function slugify(title)
	return title:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
end

--- Centralized Hugo marker check, also used by shared/overseer/hugo.lua so
--- both the LYRDSite* provider and the overseer task templates agree on
--- what counts as a Hugo project.
---@param root string
---@return string? config_file
local function find_config_file(root)
	return vim.fs.find(CONFIG_MARKERS, { upward = true, type = "file", path = root })[1]
end

---@param root string
---@return LYRD.site.AssessResult
local function assess(root)
	local found = find_config_file(root)
	if not found then
		return { is_match = false, confidence = 0, reasons = {} }
	end
	return {
		is_match = true,
		confidence = 1,
		reasons = { "found " .. vim.fs.basename(found) },
		root = vim.fs.dirname(found),
	}
end

---@param ctx {root: string}
---@param relative_path string
local function new_content_file(ctx, relative_path)
	tasks.run_task({
		cmd = "hugo",
		args = { "new", relative_path },
		cwd = ctx.root,
		name = "Hugo: New " .. relative_path,
		auto_close = true,
	})
	vim.cmd.edit(vim.fs.joinpath(ctx.root, "content", relative_path))
end

---@type LYRD.site.Provider
return {
	id = "hugo",
	display_name = "Hugo",
	assess = assess,
	find_config_file = find_config_file,
	actions = {
		new_page = {
			desc = "Create a new Hugo page",
			args = {
				{ name = "path", required = true, prompt = "Page path (e.g. about or posts/my-page)" },
			},
			run = function(ctx, args)
				new_content_file(ctx, args.path .. DEFAULT_EXTENSION)
			end,
		},
		new_article = {
			desc = "Create a new Hugo article",
			args = {
				{ name = "title", required = true, prompt = "Article title" },
			},
			run = function(ctx, args)
				local slug = slugify(args.title)
				new_content_file(ctx, DEFAULT_SECTION .. "/" .. slug .. DEFAULT_EXTENSION)
			end,
		},
		build = {
			desc = "Build the Hugo site",
			run = function(ctx)
				tasks.run_task({ cmd = "hugo", args = {}, cwd = ctx.root, name = "Hugo: Build", open_in_split = true })
			end,
		},
		serve = {
			desc = "Serve the Hugo site (with drafts)",
			run = function(ctx)
				tasks.run_task({
					cmd = "hugo",
					args = { "server", "--buildDrafts" },
					cwd = ctx.root,
					name = "Hugo: Serve",
					open_in_split = true,
				})
			end,
		},
		list_drafts = {
			desc = "List Hugo draft content",
			run = function(ctx)
				tasks.run_task({
					cmd = "hugo",
					args = { "list", "drafts" },
					cwd = ctx.root,
					name = "Hugo: List Drafts",
					open_in_split = true,
				})
			end,
		},
	},
}
