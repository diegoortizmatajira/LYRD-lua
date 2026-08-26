local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd

---@class LYRD.site.ArgSpec
---@field name string
---@field required boolean?
---@field default any?
---@field prompt string?
---@field completion string?

---@class LYRD.site.AssessResult
---@field is_match boolean
---@field confidence number
---@field reasons string[]
---@field root string?

---@class LYRD.site.ActionSpec
---@field desc string
---@field args LYRD.site.ArgSpec[]?
---@field run fun(ctx: {root: string}, args: table<string, any>)

---@class LYRD.site.Provider
---@field id string
---@field display_name string
---@field assess fun(root: string): LYRD.site.AssessResult
---@field actions table<string, LYRD.site.ActionSpec>

---@class LYRD.layer.StaticWebSite: LYRD.shared.setup.Module
local L = { name = "Static web sites: Hugo", providers = {} }

---@param provider LYRD.site.Provider
function L.register_provider(provider)
	table.insert(L.providers, provider)
end

---@param providers LYRD.site.Provider[]
---@param root string
local function detect_providers(providers, root)
	local matches = {}
	for _, provider in ipairs(providers) do
		local assessed = provider.assess(root)
		if assessed.is_match then
			table.insert(matches, { provider = provider, assess = assessed })
		end
	end
	table.sort(matches, function(a, b)
		return a.assess.confidence > b.assess.confidence
	end)
	return matches
end

---@param action LYRD.site.ActionSpec
---@param on_ready fun(args: table<string, any>)
local function collect_args(action, on_ready)
	local collected = {}
	local specs = action.args or {}

	local function prompt_next(index)
		if index > #specs then
			on_ready(collected)
			return
		end
		local spec = specs[index]
		if spec.default ~= nil then
			collected[spec.name] = spec.default
			prompt_next(index + 1)
			return
		end
		vim.ui.input({ prompt = spec.prompt or spec.name, completion = spec.completion }, function(value)
			if spec.required and (value == nil or value == "") then
				vim.notify("Cancelled", vim.log.levels.WARN)
				return
			end
			collected[spec.name] = value
			prompt_next(index + 1)
		end)
	end

	prompt_next(1)
end

---@param provider LYRD.site.Provider
---@param assessed LYRD.site.AssessResult
---@param root string
---@param action_id string
local function dispatch_to_provider(provider, assessed, root, action_id)
	local action = provider.actions[action_id]
	if not action then
		vim.notify(
			("Provider '%s' does not support action '%s'"):format(provider.display_name, action_id),
			vim.log.levels.ERROR
		)
		return
	end
	collect_args(action, function(args)
		action.run({ root = assessed.root or root }, args)
	end)
end

---@param action_id string
local function dispatch(action_id)
	local root = vim.fn.getcwd()
	local matches = detect_providers(L.providers, root)

	if #matches == 0 then
		vim.notify("No site provider detected in " .. root, vim.log.levels.WARN)
		return
	end

	if #matches == 1 then
		dispatch_to_provider(matches[1].provider, matches[1].assess, root, action_id)
		return
	end

	vim.ui.select(matches, {
		prompt = "Select site provider",
		format_item = function(match)
			return match.provider.display_name
		end,
	}, function(choice)
		if choice then
			dispatch_to_provider(choice.provider, choice.assess, root, action_id)
		end
	end)
end

function L.preparation()
	L.register_provider(require("LYRD.shared.site-providers.hugo"))
end

function L.settings()
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.hugo"))

	commands.implement("*", {
		{
			cmd.LYRDSiteNewPage,
			function()
				dispatch("new_page")
			end,
		},
		{
			cmd.LYRDSiteNewArticle,
			function()
				dispatch("new_article")
			end,
		},
		{
			cmd.LYRDSiteBuild,
			function()
				dispatch("build")
			end,
		},
		{
			cmd.LYRDSiteServe,
			function()
				dispatch("serve")
			end,
		},
		{
			cmd.LYRDSiteListDrafts,
			function()
				dispatch("list_drafts")
			end,
		},
	})
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("hugo")
end

return L
