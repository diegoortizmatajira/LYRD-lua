local M = {}

--- Loads and parses JSON data from a file.
--- @param file_path string: The path of the file to load.
--- @return table<string, integer>: A table containing the parsed data, or an empty table if the file does not exist, is empty, or contains invalid data.
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

--- Saves frecency data to a file.
--- @param file_path string: The path of the file where data will be saved.
--- @param frecency table<string, integer>: A table containing the frecency data to save.
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

--- Increments the frecency count for a given key.
--- @param frecency table<string, integer>: A table containing frecency data.
--- @param key string|nil: The key for which the frecency count should be incremented. If nil or empty, the function exits.
--- @param amount? integer: The amount to increment the frecency count by. Defaults to 1 if not provided.
function M.increment(frecency, key, amount)
	if not key or key == "" then
		return
	end
	frecency[key] = (frecency[key] or 0) + (amount or 1)
end

--- Sorts a list of items based on their frecency and optional tiebreaker logic.
--- @generic T
--- @param items T[]: The list of items to be sorted.
--- @param frecency table<string, integer>: A table containing frecency data used for sorting.
--- @param get_key fun(item: T): string|nil: A function that retrieves the key for each item.
--- @param get_tiebreaker? fun(item: T): string: An optional function that provides a tiebreaker value if frecency counts are equal.
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
