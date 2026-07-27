local M = {}

--- Lists local Docker image references (repository:tag) via the Docker CLI.
--- @return string[]
function M.list()
	local result = vim.system({ "docker", "images", "--format", "{{.Repository}}:{{.Tag}}" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify("Docker: failed to list local images.\n" .. (result.stderr or ""), vim.log.levels.ERROR)
		return {}
	end
	local images = {}
	for line in vim.gsplit(result.stdout or "", "\n", { trimempty = true }) do
		if line ~= "<none>:<none>" then
			table.insert(images, line)
		end
	end
	return images
end

return M
