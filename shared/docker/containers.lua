local M = {}

--- @class LYRD.DockerContainer
--- @field id string
--- @field name string
--- @field image string
--- @field status string

--- Lists running Docker containers via the Docker CLI.
--- @return LYRD.DockerContainer[]
function M.list()
	local result = vim.system(
		{ "docker", "ps", "--format", "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" },
		{ text = true }
	)
		:wait()
	if result.code ~= 0 then
		vim.notify("Docker: failed to list running containers.\n" .. (result.stderr or ""), vim.log.levels.ERROR)
		return {}
	end
	local containers = {}
	for line in vim.gsplit(result.stdout or "", "\n", { trimempty = true }) do
		local id, name, image, status = line:match("^(.-)\t(.-)\t(.-)\t(.*)$")
		if id then
			table.insert(containers, { id = id, name = name, image = image, status = status })
		end
	end
	return containers
end

--- Opens a Telescope picker listing running Docker containers, and invokes
--- `on_select` with the chosen container's name, or with `nil` if the picker
--- is unavailable, no containers are running, or the prompt is cancelled.
--- @param opts? {prompt_title?: string}
--- @param on_select fun(container: string|nil)
function M.picker(opts, on_select)
	opts = opts or {}
	local ok_telescope = pcall(require, "telescope")
	if not ok_telescope then
		vim.notify("Docker: telescope.nvim not available", vim.log.levels.WARN)
		on_select(nil)
		return
	end
	local containers = M.list()
	if #containers == 0 then
		vim.notify("Docker: no running containers found", vim.log.levels.WARN)
		on_select(nil)
		return
	end
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")

	pickers
		.new({}, {
			prompt_title = opts.prompt_title or "Select Docker Container",
			finder = finders.new_table({
				results = containers,
				entry_maker = function(entry)
					return {
						value = entry.name,
						display = string.format("%s  (%s)  %s", entry.name, entry.image, entry.status),
						ordinal = entry.name .. " " .. entry.image,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					on_select(selection and selection.value or nil)
				end)
				return true
			end,
		})
		:find()
end

return M
