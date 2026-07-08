-- Scans a Hybris installation on disk and produces a per-extension description
-- of jars/source paths, plus any jars not attributable to a single extension
-- ("independent" jars). Pure filesystem reads only -- no persistence, no LSP.

local HYBRIS_HOME_ENV = "HYBRIS_HOME"
local SOURCE_SUBDIRS = { "src", "gensrc", "web/src", "web/commonwebsrc", "web/testsrc", "backoffice/src", "hmc/src" }

---@class LYRD.hybris.ExtensionRecord
---@field name string
---@field path string
---@field type "platform"|"custom"|"module"|"extra-pattern"
---@field group string?
---@field enabled boolean
---@field has_source boolean
---@field lib_jars string[]
---@field bin_jars string[]
---@field classpath_jars string[]
---@field source_paths string[]

---@class LYRD.hybris.IndependentJar
---@field path string
---@field enabled boolean

---@class LYRD.hybris.ScanResult
---@field extensions table<string, LYRD.hybris.ExtensionRecord>
---@field independent_jars LYRD.hybris.IndependentJar[]
---@field import_exclusions string[]

local M = {}

---@param pattern string
---@return string[]
local function glob_list(pattern)
	return vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })
end

-- Returns the hybris installation root (the directory that contains bin/platform/).
-- HYBRIS_HOME may point to the project root (which has a hybris/ subfolder) or
-- directly to the hybris/ directory -- both conventions are handled. The result
-- is symlink-resolved: Hybris multi-repo setups commonly symlink the whole
-- platform checkout (or bin/custom specifically) into place, and every path
-- built from hybris_home downstream (extension roots, jar globs, import
-- exclusions) must be based on the real path JDTLS will actually see for
-- opened/navigated files, or exclusions/sourcePaths silently fail to match.
---@return string?
function M.find_hybris_home()
	local raw = os.getenv(HYBRIS_HOME_ENV)
	if not raw or raw == "" then
		return nil
	end
	-- Convention 1: HYBRIS_HOME = <project>/hybris/  (bin/platform directly inside)
	if vim.fn.isdirectory(raw .. "/bin/platform") == 1 then
		return vim.fn.resolve(raw)
	end
	-- Convention 2: HYBRIS_HOME = <project root>  (hybris/ is a subdirectory)
	local with_sub = raw .. "/hybris"
	if vim.fn.isdirectory(with_sub .. "/bin/platform") == 1 then
		return vim.fn.resolve(with_sub)
	end
	-- HYBRIS_HOME is set but doesn't match either convention; return raw so the
	-- caller can show a meaningful error with the resolved path.
	if vim.fn.isdirectory(raw) == 1 then
		return vim.fn.resolve(raw)
	end
	return nil
end

-- Nearest ancestor directory that IS a Hybris extension root (i.e. directly
-- contains extensioninfo.xml), walking up from start_path. Used to scope a
-- per-extension tool (e.g. an XML language server instance) so it stays
-- small and resolves that extension's own generated schemas. Returns the
-- extension directory (symlink-resolved) or nil.
---@param start_path string?
---@return string?
function M.find_extension_root(start_path)
	if not start_path or start_path == "" then
		return nil
	end
	local found = vim.fs.find("extensioninfo.xml", { path = start_path, upward = true, type = "file" })
	if found[1] then
		return vim.fn.resolve(vim.fs.dirname(found[1]))
	end
	return nil
end

-- Locates a generated schema file named `basename` (e.g. "items.xsd",
-- "beans.xsd", "extensioninfo.xsd") anywhere under `root`. Prefers `fd`
-- (fast, parallel, symlink-aware) and falls back to vim.fs.find. Used to
-- associate Hybris schemas with their XML so a schema-aware XML language
-- server can complete elements/attributes/enums. The generated grammar is
-- identical across extensions, so one representative file per type is
-- enough to drive completion for every matching XML. Returns an absolute
-- path or nil.
---@param root string?
---@param basename string?
---@return string?
function M.find_schema(root, basename)
	if not root or root == "" or not basename or basename == "" then
		return nil
	end
	if vim.fn.executable("fd") == 1 then
		local pattern = "^" .. basename:gsub("%.", "\\.") .. "$"
		local results = vim.fn.systemlist({ "fd", "-L", "-t", "f", "-a", "--", pattern, root })
		if vim.v.shell_error == 0 and #results > 0 then
			return results[1]
		end
	end
	local hits = vim.fs.find(basename, { path = root, type = "file", limit = 1 })
	return hits[1]
end

-- Directories that never hold a Hybris extension root but are expensive to
-- walk into (build output, vendored JS deps, VCS metadata).
local SKIP_DIRS = {
	["node_modules"] = true,
	["bower_components"] = true,
	[".git"] = true,
	[".svn"] = true,
	["dist"] = true,
	["build"] = true,
	["classes"] = true,
	["testclasses"] = true,
}

-- Pure-Lua recursive fallback (used when `fd` is unavailable). Collects every
-- extensioninfo.xml under `dir`. Prunes once an extension root is found --
-- Hybris extensions are siblings, never nested inside one another -- so it
-- never wastes time walking into an extension's own src/bin/web output
-- looking for extensions that can't be there. Follows symlinks via fs_stat,
-- with a depth cap and a visited-set as loop guards.
---@param dir string
---@param acc string[]?
---@param depth integer?
---@param seen table<string, boolean>?
---@return string[]
local function scan_extensioninfo(dir, acc, depth, seen)
	acc = acc or {}
	depth = depth or 0
	seen = seen or {}
	if depth > 40 then
		return acc
	end

	local uv = vim.uv or vim.loop
	local real = uv.fs_realpath(dir)
	if real then
		if seen[real] then
			return acc
		end
		seen[real] = true
	end

	local handle = uv.fs_scandir(dir)
	if not handle then
		return acc
	end

	local subdirs = {}
	local found_here = false
	while true do
		local name, typ = uv.fs_scandir_next(handle)
		if not name then
			break
		end
		local full = dir .. "/" .. name
		if name == "extensioninfo.xml" then
			table.insert(acc, full)
			found_here = true
		elseif not SKIP_DIRS[name] then
			if typ == nil or typ == "link" then
				local st = uv.fs_stat(full)
				typ = st and st.type or nil
			end
			if typ == "directory" then
				table.insert(subdirs, full)
			end
		end
	end

	if not found_here then
		for _, sub in ipairs(subdirs) do
			scan_extensioninfo(sub, acc, depth + 1, seen)
		end
	end
	return acc
end

-- Locates every extensioninfo.xml under base_dir. Prefers `fd` (fast,
-- parallel, symlink-aware via -L) and falls back to the pruning pure-Lua scan
-- above when `fd` isn't installed or the search returns nothing.
---@param base_dir string
---@return string[]
local function find_extensioninfo_files(base_dir)
	if vim.fn.executable("fd") == 1 then
		local results = vim.fn.systemlist({
			"fd",
			"-L",
			"-t",
			"f",
			"-a",
			"--",
			"^extensioninfo\\.xml$",
			base_dir,
		})
		if vim.v.shell_error == 0 and #results > 0 then
			return results
		end
	end
	return scan_extensioninfo(base_dir)
end

-- Locates all Hybris extension root directories inside base_dir by finding
-- extensioninfo.xml files at any nesting depth (handles group folders like
-- bin/ext-company/group/extname/ where the extension is 3 levels deep). Each
-- root is symlink-resolved for the same reason find_hybris_home() resolves
-- its result: everything derived from it (jar globs, source dirs) must match
-- the real path JDTLS sees for the corresponding buffers.
---@param base_dir string
---@return string[]
local function find_extension_roots(base_dir)
	local roots = {}
	for _, ext_info in ipairs(find_extensioninfo_files(base_dir)) do
		table.insert(roots, vim.fn.resolve(vim.fn.fnamemodify(ext_info, ":h")))
	end
	return roots
end

-- Reads localextensions.xml to determine which extensions are active in this
-- project. Returns a set of extension names (name -> true), or nil when the
-- file is absent (callers treat nil as "include all"). XML comments are
-- stripped first so a commented-out `<extension name="foo"/>` (a common way
-- to temporarily disable one) is correctly excluded rather than read as active.
---@param hybris_home string
---@return table<string, boolean>?
function M.collect_active_extension_names(hybris_home)
	local path = hybris_home .. "/config/localextensions.xml"
	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end
	local content = table.concat(vim.fn.readfile(path), "\n")
	content = content:gsub("<!%-%-(.-)%-%->", "")
	local active = {}
	for name in content:gmatch('<extension%s+name="([^"]+)"') do
		active[name] = true
	end
	return active
end

-- Deduplicates paths after resolving both to an absolute form AND through any
-- symlinks, so two routes to the same physical file (e.g. via a symlinked
-- bin/custom vs. its real target) collapse to one entry.
---@param paths string[]
---@return string[]
function M.deduplicate_paths(paths)
	local seen = {}
	local result = {}
	for _, p in ipairs(paths) do
		local norm = vim.fn.resolve(vim.fn.fnamemodify(p, ":p"))
		if not seen[norm] then
			seen[norm] = true
			table.insert(result, norm)
		end
	end
	return result
end

---@param ext_root string
---@return boolean
local function has_source_dirs(ext_root)
	return vim.fn.isdirectory(ext_root .. "/src") == 1 or vim.fn.isdirectory(ext_root .. "/gensrc") == 1
end

---@param ext_root string
---@return string[]
local function collect_source_paths(ext_root)
	local paths = {}
	for _, subdir in ipairs(SOURCE_SUBDIRS) do
		local candidate = ext_root .. "/" .. subdir
		if vim.fn.isdirectory(candidate) == 1 then
			table.insert(paths, candidate)
		end
	end
	return paths
end

-- Scans an extension's own .classpath file(s) for Eclipse "kind=lib" entries
-- (third-party jars referenced outside the standard lib/ convention).
---@param ext_root string
---@return string[]
local function collect_classpath_jars(ext_root)
	local jars = {}
	for _, cp_file in ipairs(glob_list(ext_root .. "/**/.classpath")) do
		for _, line in ipairs(vim.fn.readfile(cp_file)) do
			if line:find('kind="lib"') then
				local path = line:match('path="([^"]+)"')
				if path then
					if not path:match("^/") then
						path = vim.fn.fnamemodify(cp_file, ":h") .. "/" .. path
					end
					path = vim.fn.fnamemodify(path, ":p")
					if vim.fn.filereadable(path) == 1 then
						table.insert(jars, path)
					end
				end
			end
		end
	end
	return jars
end

---@param ext_root string
---@param ext_type "platform"|"custom"|"module"|"extra-pattern"
---@param group string?
---@param active_extensions table<string, boolean>?
---@return LYRD.hybris.ExtensionRecord
local function scan_extension(ext_root, ext_type, group, active_extensions)
	local name = vim.fn.fnamemodify(ext_root, ":t")
	local enabled = ext_type == "platform" or active_extensions == nil or active_extensions[name] == true
	return {
		name = name,
		path = ext_root,
		type = ext_type,
		group = group,
		enabled = enabled,
		has_source = has_source_dirs(ext_root),
		lib_jars = M.deduplicate_paths(glob_list(ext_root .. "/lib/*.jar")),
		bin_jars = M.deduplicate_paths(glob_list(ext_root .. "/bin/*.jar")),
		classpath_jars = M.deduplicate_paths(collect_classpath_jars(ext_root)),
		source_paths = collect_source_paths(ext_root),
	}
end

-- Builds the java.import.exclusions list that prevents JDTLS from treating
-- individual Hybris extensions as standalone Eclipse projects. Without these,
-- JDTLS finds .classpath/.project files in each extension root and enters
-- Eclipse-project mode for those files, which resolves cross-extension types
-- from compiled JARs only -- completely ignoring our sourcePaths configuration.
-- With the exclusions, extension directories skip Eclipse/Maven/Gradle project
-- detection and fall back to invisible-project mode, where sourcePaths applies
-- globally and source changes are visible without a rebuild.
---@param hybris_home string
---@param extra_patterns string[]
---@return string[]
local function build_import_exclusions(hybris_home, extra_patterns)
	-- Every documented default for java.import.exclusions (vscode-java's own
	-- **/node_modules/**, **/.metadata/**, etc.) is a relative, **/-prefixed
	-- pattern -- never an absolute filesystem path. hybris_home is frequently a
	-- SUBDIRECTORY of the actual jdtls root_dir (e.g. root_dir is the git root,
	-- hybris_home is <root_dir>/hybris), so if JDT relativizes paths against
	-- root_dir before matching, an absolute-anchored pattern never matches
	-- anything -- every extension then keeps its own .classpath/.project and
	-- gets treated as a separate Eclipse project, exactly the "not on the
	-- classpath, only syntax errors reported" failure this setting exists to
	-- prevent. Emit BOTH forms so it works regardless of which one JDT's
	-- matcher actually expects.
	local targets = { "bin/platform/ext", "bin/modules", "bin/custom" }
	for _, p in ipairs(extra_patterns) do
		table.insert(targets, "bin/" .. p)
	end

	local exclusions = {}
	for _, target in ipairs(targets) do
		table.insert(exclusions, hybris_home .. "/" .. target .. "/**")
		table.insert(exclusions, "**/" .. target .. "/**")
	end
	return exclusions
end

---@param jar_path string
---@param known_roots table<string, boolean>
---@return boolean
local function jar_belongs_to_known_root(jar_path, known_roots)
	local abs = vim.fn.fnamemodify(jar_path, ":p")
	for root in pairs(known_roots) do
		if abs:sub(1, #root) == root then
			return true
		end
	end
	return false
end

-- Jars not owned by any single extension folder: platform-core jars, jars sitting
-- directly at a module-group/extra-pattern root (not inside an extension
-- subfolder), and a safety net for platform ext jars that don't map to any
-- extension root found via extensioninfo.xml (e.g. a malformed extension dir).
---@param hybris_home string
---@param known_roots table<string, boolean>
---@param module_dirs string[]
---@param extra_top_dirs string[]
---@return LYRD.hybris.IndependentJar[]
local function collect_independent_jars(hybris_home, known_roots, module_dirs, extra_top_dirs)
	local jars = {}
	vim.list_extend(jars, glob_list(hybris_home .. "/bin/platform/lib/*.jar"))
	vim.list_extend(jars, glob_list(hybris_home .. "/bin/platform/bootstrap/bin/*.jar"))
	vim.list_extend(jars, glob_list(hybris_home .. "/bin/platform/tomcat/lib/*.jar"))

	local legacy = {}
	vim.list_extend(legacy, glob_list(hybris_home .. "/bin/platform/ext/*/lib/*.jar"))
	vim.list_extend(legacy, glob_list(hybris_home .. "/bin/platform/ext/*/bin/*.jar"))
	for _, jar in ipairs(legacy) do
		if not jar_belongs_to_known_root(jar, known_roots) then
			table.insert(jars, jar)
		end
	end

	for _, dir in ipairs(module_dirs) do
		vim.list_extend(jars, glob_list(dir .. "/*.jar"))
	end
	for _, dir in ipairs(extra_top_dirs) do
		vim.list_extend(jars, glob_list(dir .. "/*.jar"))
	end

	local result = {}
	for _, path in ipairs(M.deduplicate_paths(jars)) do
		table.insert(result, { path = path, enabled = true })
	end
	return result
end

-- Scans the full Hybris installation and returns a per-extension breakdown of
-- jars/source paths, independent jars, and JDTLS import exclusions.
---@param hybris_home string
---@param extra_patterns string[]
---@return LYRD.hybris.ScanResult
function M.scan(hybris_home, extra_patterns)
	extra_patterns = extra_patterns or {}
	local active_extensions = M.collect_active_extension_names(hybris_home)
	local extensions = {}
	local known_roots = {}

	---@param base_dir string
	---@param ext_type "platform"|"custom"|"module"|"extra-pattern"
	---@param group string?
	local function add_extensions(base_dir, ext_type, group)
		for _, ext_root in ipairs(find_extension_roots(base_dir)) do
			known_roots[vim.fn.fnamemodify(ext_root, ":p")] = true
			local record = scan_extension(ext_root, ext_type, group, active_extensions)
			extensions[record.name] = record
		end
	end

	add_extensions(hybris_home .. "/bin/platform/ext", "platform", nil)
	add_extensions(hybris_home .. "/bin/custom", "custom", nil)

	local module_dirs = {}
	for _, group_dir in ipairs(glob_list(hybris_home .. "/bin/modules/*")) do
		if vim.fn.isdirectory(group_dir) == 1 then
			table.insert(module_dirs, group_dir)
			add_extensions(group_dir, "module", vim.fn.fnamemodify(group_dir, ":t"))
		end
	end

	local extra_top_dirs = {}
	for _, pattern in ipairs(extra_patterns) do
		for _, top_dir in ipairs(glob_list(hybris_home .. "/bin/" .. pattern)) do
			if vim.fn.isdirectory(top_dir) == 1 then
				table.insert(extra_top_dirs, top_dir)
				add_extensions(top_dir, "extra-pattern", pattern)
			end
		end
	end

	return {
		extensions = extensions,
		independent_jars = collect_independent_jars(hybris_home, known_roots, module_dirs, extra_top_dirs),
		import_exclusions = build_import_exclusions(hybris_home, extra_patterns),
	}
end

return M
