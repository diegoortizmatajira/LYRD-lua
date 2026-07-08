-- Pure resolution of a scanned/persisted Hybris solution config into the shape
-- JDTLS expects, honoring per-extension and per-jar enabled flags. No I/O, no
-- LSP calls -- reused by Import, Reload, Configure-save, and the current-config
-- display.

local scanner = require("LYRD.shared.hybris.scanner")

local M = {}

---@class LYRD.hybris.Resolved
---@field referencedLibraries string[]
---@field sourcePaths string[]
---@field import_exclusions string[]

-- Walks enabled extensions and independent jars to build the flat lists JDTLS
-- consumes. A disabled extension contributes nothing (decision: fully
-- excluded). An enabled extension's bin/*.jar is only included when it has no
-- source -- when source is present, sourcePaths covers it and the compiled jar
-- would just be a redundant/stale duplicate.
---@param config table
---@return LYRD.hybris.Resolved
function M.resolve(config)
	local jars = {}
	local source_paths = {}

	for _, ext in pairs(config.extensions or {}) do
		if ext.enabled then
			vim.list_extend(jars, ext.lib_jars or {})
			vim.list_extend(jars, ext.classpath_jars or {})
			if not ext.has_source then
				vim.list_extend(jars, ext.bin_jars or {})
			end
			vim.list_extend(source_paths, ext.source_paths or {})
		end
	end

	for _, jar in ipairs(config.independent_jars or {}) do
		if jar.enabled ~= false then
			table.insert(jars, jar.path)
		end
	end

	return {
		referencedLibraries = scanner.deduplicate_paths(jars),
		sourcePaths = scanner.deduplicate_paths(source_paths),
		import_exclusions = config.import_exclusions or {},
	}
end

---@param resolved LYRD.hybris.Resolved
---@param workspace_root string? Workspace root for making sourcePaths relative. If omitted, paths are used as-is.
---@return table
function M.to_jdtls_settings(resolved, workspace_root)
	local source_paths = resolved.sourcePaths

	-- JDTLS's invisible project importer requires sourcePaths to be relative to
	-- the workspace root. Convert absolute paths to relative.
	if workspace_root and workspace_root ~= "" then
		source_paths = {}
		for _, abs_path in ipairs(resolved.sourcePaths) do
			local rel_path = abs_path
			-- Make relative to workspace_root by removing the prefix
			if abs_path:sub(1, #workspace_root) == workspace_root then
				rel_path = abs_path:sub(#workspace_root + 2)  -- +2 to skip the leading /
			end
			table.insert(source_paths, rel_path)
		end
	end

	return {
		settings = {
			java = {
				project = {
					referencedLibraries = resolved.referencedLibraries,
					sourcePaths = source_paths,
				},
				-- Prevent JDTLS from treating each extension as a standalone Eclipse
				-- project (via .classpath/.project files). In Eclipse-project mode,
				-- cross-extension types are resolved from compiled JARs only and
				-- sourcePaths is ignored. With these exclusions, extensions fall into
				-- invisible-project mode where sourcePaths applies globally.
				import = {
					exclusions = resolved.import_exclusions,
				},
			},
		},
	}
end

return M
