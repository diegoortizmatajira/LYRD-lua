-- Makes jdtls see annotation-processor output (MapStruct, Lombok, Querydsl,
-- OpenAPI generators...) that Maven writes under target/generated-sources.
--
-- m2e's `.classpath` lists `target/generated-sources` as one source root, and
-- nested roots such as `target/generated-sources/<gen>/src/main/java` end up
-- skipped by jdtls, so generated types show up as unresolved. This patches each
-- module's `.classpath` to (1) add the nested roots as their own source entries
-- and (2) exclude them from the parent entry so they are not seen twice.
--
-- Ported from nvim-java's `java.experimental.fix-generated-sources`
-- (https://github.com/nvim-java/nvim-java, Apache-2.0).
local join = require("LYRD.shared.utils").join_paths

local M = {}

-- Directories that never contain a module's `.classpath` but can be huge.
local SKIPPED_DIRS = { [".git"] = true, [".idea"] = true, ["node_modules"] = true, ["target"] = true }
local MAX_DEPTH = 6
local MAX_FILES = 500

---@param p string
---@return string
local function normalize(p)
	return (p:gsub("\\", "/"))
end

---@param root string
---@param absolute_path string
---@return string
local function relative_path(root, absolute_path)
	local prefix = normalize(root) .. "/"
	local path = normalize(absolute_path)
	if path:sub(1, #prefix) == prefix then
		return path:sub(#prefix + 1)
	end
	return path
end

--- Merges `exclusions` into the `excluding` attribute of a classpathentry line.
---@param line string
---@param exclusions string[]
---@return string
local function set_exclusions(line, exclusions)
	local merged = {}
	local existing = line:match('excluding="([^"]+)"')
	if existing then
		for entry in existing:gmatch("[^|]+") do
			merged[entry] = true
		end
	end
	for _, exclusion in ipairs(exclusions) do
		merged[exclusion] = true
	end
	local value = table.concat(vim.fn.sort(vim.tbl_keys(merged)), "|")
	if existing then
		return (line:gsub('excluding="[^"]+"', function()
			return 'excluding="' .. value .. '"'
		end, 1))
	end
	return (line:gsub("<classpathentry ", function()
		return '<classpathentry excluding="' .. value .. '" '
	end, 1))
end

---@param lines string[]
---@param entry_path string
---@return boolean
local function has_entry(lines, entry_path)
	local needle = 'path="' .. entry_path .. '"'
	for _, line in ipairs(lines) do
		if line:find(needle, 1, true) then
			return true
		end
	end
	return false
end

---@param lines string[]
---@return integer|nil
local function find_generated_sources_entry(lines)
	for index, line in ipairs(lines) do
		if line:find('path="target/generated%-sources"') or line:find("path='target/generated%-sources'") then
			return index
		end
	end
end

--- Inserts a source entry before the `output` entry.
---@param lines string[]
---@param entry_path string
local function add_entry(lines, entry_path)
	local entry = {
		'\t<classpathentry kind="src" output="target/classes" path="' .. entry_path .. '">',
		"\t\t<attributes>",
		'\t\t\t<attribute name="optional" value="true"/>',
		'\t\t\t<attribute name="maven.pomderived" value="true"/>',
		"\t\t</attributes>",
		"\t</classpathentry>",
	}
	local at = #lines + 1
	for index, line in ipairs(lines) do
		if line:find('<classpathentry kind="output"', 1, true) then
			at = index
			break
		end
	end
	for offset = #entry, 1, -1 do
		table.insert(lines, at, entry[offset])
	end
end

--- Finds `*/src/<set>/java` roots under target/generated-sources, relative to the module.
---@param module_root string
---@return string[]
local function generated_source_roots(module_root)
	local generated_root = join(module_root, "target", "generated-sources")
	if not vim.uv.fs_stat(generated_root) then
		return {}
	end
	local java_dirs = vim.fs.find(function(name)
		return name == "java"
	end, { path = generated_root, type = "directory", limit = 500 })

	local roots, seen = {}, {}
	for _, java_dir in ipairs(java_dirs) do
		local segments = vim.split(relative_path(generated_root, java_dir), "/", { plain = true })
		local count = #segments
		if count >= 3 and segments[count - 2] == "src" then
			local root = relative_path(module_root, java_dir)
			if not seen[root] then
				seen[root] = true
				table.insert(roots, root)
			end
		end
	end
	table.sort(roots)
	return roots
end

--- Exclusions for the parent entry: the nested generator dirs, plus `annotations/`
--- (the Maven/Eclipse convention for compiled annotation processor output).
---@param roots string[]
---@return string[]
local function parent_exclusions(roots)
	local exclusions = { ["annotations/"] = true }
	local prefix = "target/generated-sources/"
	for _, root in ipairs(roots) do
		if root:sub(1, #prefix) == prefix then
			local first = vim.split(root:sub(#prefix + 1), "/", { plain = true })[1]
			if first then
				exclusions[first .. "/"] = true
			end
		end
	end
	return vim.fn.sort(vim.tbl_keys(exclusions))
end

--- Idempotent: re-running on an already patched file changes nothing.
---@param classpath_file string
---@return boolean changed
local function patch_classpath(classpath_file)
	local lines = vim.fn.readfile(classpath_file)
	local parent_index = find_generated_sources_entry(lines)
	if not parent_index then
		return false
	end

	local module_root = vim.fs.dirname(classpath_file)
	local roots = generated_source_roots(module_root)
	local changed = false

	local patched = set_exclusions(lines[parent_index], parent_exclusions(roots))
	if patched ~= lines[parent_index] then
		lines[parent_index] = patched
		changed = true
	end
	for _, root in ipairs(roots) do
		if not has_entry(lines, root) then
			add_entry(lines, root)
			changed = true
		end
	end

	if changed then
		vim.fn.writefile(lines, classpath_file)
	end
	return changed
end

---@param root string
---@return string[]
local function find_classpath_files(root)
	local found = {}
	for name, type in
		vim.fs.dir(root, {
			depth = MAX_DEPTH,
			skip = function(dir)
				return not SKIPPED_DIRS[vim.fs.basename(dir)]
			end,
		})
	do
		if type == "file" and vim.fs.basename(name) == ".classpath" then
			table.insert(found, join(root, name))
			if #found >= MAX_FILES then
				break
			end
		end
	end
	return found
end

--- Patches every module `.classpath` under `root`. Only runs for Maven projects
--- (a pom.xml in `root`); set $NVIM_JDTLS_NO_FIX_GENERATED_SOURCES=1 to disable.
---@param root string Project root directory
---@return integer patched Number of `.classpath` files modified
function M.patch(root)
	if vim.env.NVIM_JDTLS_NO_FIX_GENERATED_SOURCES == "1" or vim.fn.filereadable(join(root, "pom.xml")) == 0 then
		return 0
	end
	local patched = 0
	for _, file in ipairs(find_classpath_files(root)) do
		if patch_classpath(file) then
			patched = patched + 1
		end
	end
	if patched > 0 then
		vim.notify(
			string.format("jdtls: added generated-sources roots to %d .classpath file(s)", patched),
			vim.log.levels.INFO
		)
	end
	return patched
end

return M
