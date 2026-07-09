-- Persists a scanned Hybris solution config as JSON, keyed by a hash of the
-- Neovim project root, so a dev working across multiple Hybris checkouts gets
-- one independent cache per project.

local utils = require("LYRD.shared.utils")

local M = {}

---@param project_root string
---@return string
local function hash_project_root(project_root)
	local normalized = vim.fn.fnamemodify(project_root, ":p:h")
	return (normalized:gsub("[/\\:+-]", "_"))
end

---@param project_root string
---@return string
function M.cache_path(project_root)
	return utils.get_lyrd_data_path(utils.join_paths("hybris", hash_project_root(project_root), "solution.json"))
end

---@param project_root string
---@return boolean
function M.exists(project_root)
	return vim.fn.filereadable(M.cache_path(project_root)) == 1
end

-- Returns the persisted config, or nil when no cache exists yet or the file is
-- corrupt -- callers use nil to distinguish "never imported" from "imported
-- but resolves to nothing".
---@param project_root string
---@return table?
function M.load(project_root)
	local path = M.cache_path(project_root)
	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end
	local content = table.concat(vim.fn.readfile(path), "\n")
	if content == "" then
		return nil
	end
	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		return nil
	end
	return data
end

---@param project_root string
---@param config table
---@return boolean
function M.save(project_root, config)
	local path = M.cache_path(project_root)
	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok, encoded = pcall(vim.json.encode, config)
	if not ok then
		vim.notify("Hybris: could not encode solution config", vim.log.levels.ERROR)
		return false
	end
	vim.fn.writefile(vim.split(encoded, "\n", { plain = true }), path)
	return true
end

return M
