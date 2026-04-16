local M = {}

--- @param file_path string
--- @return table<string, integer>
function M.load(file_path)
	if vim.fn.filereadable(file_path) == 0 then
		return {}
	end
	local content = table.concat(vim.fn.readfile(file_path), "\n")
	if content == "" then
		return {}
	end
	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		return {}
	end
	return data
end

--- @param file_path string
--- @param frecency table<string, integer>
function M.save(file_path, frecency)
	local dir = vim.fn.fnamemodify(file_path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok, encoded = pcall(vim.json.encode, frecency)
	if not ok then
		vim.notify("Could not encode frecency data", vim.log.levels.ERROR)
		return
	end
	vim.fn.writefile(vim.split(encoded, "\n", { plain = true }), file_path)
end

--- @param frecency table<string, integer>
--- @param key string|nil
--- @param amount? integer
function M.increment(frecency, key, amount)
	if not key or key == "" then
		return
	end
	frecency[key] = (frecency[key] or 0) + (amount or 1)
end

--- @generic T
--- @param items T[]
--- @param frecency table<string, integer>
--- @param get_key fun(item: T): string|nil
--- @param get_tiebreaker? fun(item: T): string
function M.sort(items, frecency, get_key, get_tiebreaker)
	table.sort(items, function(a, b)
		local a_key = get_key(a) or ""
		local b_key = get_key(b) or ""
		local a_count = frecency[a_key] or 0
		local b_count = frecency[b_key] or 0
		if a_count == b_count then
			if get_tiebreaker then
				return get_tiebreaker(a) < get_tiebreaker(b)
			end
			return a_key < b_key
		end
		return a_count > b_count
	end)
end

return M
