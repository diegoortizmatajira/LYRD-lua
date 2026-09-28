local utils = require("LYRD.shared.utils")

--- @class LYRD.shared.CssDiscovery
local M = {}

-- Captured once, at module load time (which happens during LYRD's synchronous
-- startup sequence, before any `:cd`/`:lcd`). `jezda1337/nvim-html-css` resolves
-- its own relative `style_sheets` entries against its module's load-time cwd
-- (see its `lua/html-css/init.lua`), not against the live cwd. Every path this
-- module hands back is expressed relative to this same value so it lines up
-- with how the plugin will actually resolve it, regardless of where the
-- detected project root sits relative to it.
local startup_cwd = vim.fn.getcwd()

local ROOT_MARKERS = { "package.json", "vite.config.js", "vite.config.ts", "vue.config.js", ".git" }

local STYLE_EXTENSIONS = { css = true, scss = true, sass = true, less = true }

local JS_LIKE_EXTENSIONS = { js = true, mjs = true, cjs = true, jsx = true, ts = true, tsx = true }

local TREESITTER_LANG_BY_EXT = {
	js = "javascript",
	mjs = "javascript",
	cjs = "javascript",
	jsx = "javascript",
	ts = "typescript",
	tsx = "tsx",
}

-- Extensions/suffixes tried, in order, when a bare or extension-less import
-- specifier is resolved to an actual file on disk. Style extensions are
-- included (not just JS-like ones) because packages commonly expose CSS via
-- an extension-less subpath, e.g. `import 'vuetify/styles'`.
local RESOLUTION_SUFFIXES = {
	"",
	".css",
	".scss",
	".sass",
	".less",
	".ts",
	".tsx",
	".js",
	".jsx",
	".mjs",
	".cjs",
	"/index.css",
	"/index.scss",
	"/index.ts",
	"/index.tsx",
	"/index.js",
	"/index.jsx",
}

local IMPORT_QUERY = [[
(import_statement
  (string (string_fragment) @import_path))
]]

--- Per-project-root cache of discovered stylesheets, so repeated buffer
--- entries into the same project don't re-walk the import graph every time.
--- @type table<string, string[]>
local root_cache = {}

--- @param path string
--- @return boolean
local function is_stylesheet(path)
	local ext = path:match("%.([%w]+)$")
	return ext ~= nil and STYLE_EXTENSIONS[ext] == true
end

--- @param path string
--- @return boolean
local function file_exists(path)
	return vim.fn.filereadable(path) == 1
end

--- Computes `target` expressed as a path relative to `base`, using `../`
--- segments when `target` is not a descendant of `base`.
--- @param target string Absolute path to express relatively.
--- @param base string Absolute path to express it relative to.
--- @return string
function M.relpath(target, base)
	target = vim.fs.normalize(target)
	base = vim.fs.normalize(base)

	local target_parts = vim.split(target, "/", { trimempty = true })
	local base_parts = vim.split(base, "/", { trimempty = true })

	local common = 1
	while target_parts[common] and base_parts[common] and target_parts[common] == base_parts[common] do
		common = common + 1
	end

	local parts = {}
	for _ = common, #base_parts do
		table.insert(parts, "..")
	end
	local up_count = #parts
	for i = common, #target_parts do
		table.insert(parts, target_parts[i])
	end

	if #parts == 0 then
		return "."
	end
	local rel = table.concat(parts, "/")
	if up_count == 0 then
		rel = "./" .. rel
	end
	return rel
end

--- Resolves an import specifier found in `importer_dir` to an absolute path
--- on disk, trying common extensions/`index` files when the specifier has
--- none. Returns `nil` when nothing on disk matches.
---
--- Supported specifier shapes: relative (`./foo`, `../foo`), the conventional
--- Vite/Vue `@/` alias for `<root>/src`, root-absolute (`/foo`, treated as
--- relative to the project root), and bare package specifiers (resolved
--- under `<root>/node_modules`). Arbitrary aliases configured in
--- `vite.config.*`/`tsconfig.json` are not read — `@/` is special-cased
--- because it is the default scaffold convention.
--- @param spec string
--- @param importer_dir string
--- @param root string
--- @return string|nil
function M.resolve_import(spec, importer_dir, root)
	if not spec or spec == "" then
		return nil
	end

	local base
	if spec:sub(1, 1) == "." then
		base = vim.fs.normalize(vim.fs.joinpath(importer_dir, spec))
	elseif spec:sub(1, 2) == "@/" then
		base = vim.fs.normalize(vim.fs.joinpath(root, "src", spec:sub(3)))
	elseif spec:sub(1, 1) == "/" then
		base = vim.fs.normalize(vim.fs.joinpath(root, spec:sub(2)))
	else
		base = vim.fs.normalize(vim.fs.joinpath(root, "node_modules", spec))
	end

	if file_exists(base) then
		return base
	end
	for _, suffix in ipairs(RESOLUTION_SUFFIXES) do
		local candidate = base .. suffix
		if file_exists(candidate) then
			return candidate
		end
	end
	return nil
end

--- Fallback regex-based import extraction, used when Tree-sitter parsing of
--- a file fails (e.g. a parser isn't installed) or yields nothing.
--- @param text string
--- @return string[]
local function extract_imports_regex(text)
	local imports = {}
	for spec in text:gmatch("import%s+[^'\"\n]-from%s+['\"]([^'\"]+)['\"]") do
		table.insert(imports, spec)
	end
	for spec in text:gmatch("import%s+['\"]([^'\"]+)['\"]") do
		table.insert(imports, spec)
	end
	return imports
end

--- Extracts the module specifiers of every top-level `import` statement in a
--- JS/TS file. `.vue` files are never passed in here: import-graph recursion
--- intentionally stops at `.vue` boundaries (see module docs / issue #11) --
--- component-level styles are already picked up by nvim-html-css itself when
--- that component's buffer is opened directly.
--- @param file string Absolute path to a .js/.mjs/.cjs/.jsx/.ts/.tsx file.
--- @return string[]
function M.extract_imports(file)
	local ext = file:match("%.([%w]+)$")
	local lang = TREESITTER_LANG_BY_EXT[ext]
	if not lang then
		return {}
	end

	local ok_read, lines = pcall(vim.fn.readfile, file)
	if not ok_read then
		return {}
	end
	local text = table.concat(lines, "\n")

	local imports = {}
	local ok_ts = pcall(function()
		local parser = vim.treesitter.get_string_parser(text, lang)
		local tree = parser:parse()[1]
		local query = vim.treesitter.query.parse(lang, IMPORT_QUERY)
		for _, node in query:iter_captures(tree:root(), text) do
			table.insert(imports, vim.treesitter.get_node_text(node, text))
		end
	end)

	if not ok_ts or #imports == 0 then
		imports = extract_imports_regex(text)
	end

	return imports
end

--- @param root string
--- @return string[] absolute paths to try as project entry points
local function discover_entry_points(root)
	local candidates = {}

	local index_html = vim.fs.joinpath(root, "index.html")
	if file_exists(index_html) then
		local ok, lines = pcall(vim.fn.readfile, index_html)
		if ok then
			local content = table.concat(lines, "\n")
			for tag in content:gmatch("<script[^>]->") do
				if tag:match('type%s*=%s*"module"') then
					local src = tag:match('src%s*=%s*"([^"]+)"')
					if src then
						local resolved = M.resolve_import(src, root, root)
						if resolved then
							table.insert(candidates, resolved)
						end
					end
				end
			end
		end
	end

	if #candidates == 0 then
		local fallbacks = { "src/main.ts", "src/main.js", "src/main.mjs", "src/main.jsx", "src/main.tsx" }
		for _, rel in ipairs(fallbacks) do
			local abs = vim.fs.joinpath(root, rel)
			if file_exists(abs) then
				table.insert(candidates, abs)
			end
		end
	end

	return candidates
end

--- Walks the import graph of a project starting from its entry point(s),
--- returning every `.css`/`.scss`/`.sass`/`.less` file reachable through
--- `.js`/`.ts`/`.jsx`/`.tsx` imports (including into `node_modules`).
--- Recursion stops at `.css`-family files (leaves) and at `.vue` files
--- (boundary -- see `M.extract_imports`).
--- @param root string Absolute path to the project root.
--- @return string[] absolute paths to discovered stylesheets, deduplicated
function M.scan_project(root)
	local visited = {}
	local stylesheets = {}
	local stylesheets_seen = {}
	local queue = discover_entry_points(root)

	while #queue > 0 do
		local file = table.remove(queue)
		if file and not visited[file] then
			visited[file] = true
			if is_stylesheet(file) then
				if not stylesheets_seen[file] then
					stylesheets_seen[file] = true
					table.insert(stylesheets, file)
				end
			else
				local ext = file:match("%.([%w]+)$")
				if ext and JS_LIKE_EXTENSIONS[ext] then
					local dir = vim.fs.dirname(file)
					for _, spec in ipairs(M.extract_imports(file)) do
						local resolved = M.resolve_import(spec, dir, root)
						if resolved and not visited[resolved] then
							table.insert(queue, resolved)
						end
					end
				end
				-- `.vue` (and anything else unrecognized) is a dead end: not
				-- recursed into, matching the "stop at .vue boundary" design.
			end
		end
	end

	return stylesheets
end

--- Finds the current buffer's project root using the same marker-based
--- search as the rest of LYRD (`LYRD.shared.utils.find_root_dir`).
--- @return string|nil
function M.find_project_root()
	return utils.find_root_dir(ROOT_MARKERS)
end

--- Expands a path relative to `startup_cwd` (as returned by
--- `M.discover_for_current_buffer`/stored in `style_sheets`) back into an
--- absolute path. Remote (`http(s)://`) entries are returned unchanged.
--- @param path string
--- @return string
function M.to_absolute(path)
	if path:match("^https?://") then
		return path
	end
	return vim.fs.normalize(vim.fs.joinpath(startup_cwd, path))
end

--- Whether a `style_sheets` entry is usable: remote entries are always
--- assumed reachable (fetched lazily by nvim-html-css itself); local entries
--- must exist on disk relative to `startup_cwd`. Used to drop stale/invalid
--- configured entries (e.g. a leftover `"./index.css"` in a project that
--- doesn't have one) before they're handed to nvim-html-css.
--- @param path string
--- @return boolean
function M.exists(path)
	if path:match("^https?://") then
		return true
	end
	return file_exists(M.to_absolute(path))
end

--- Filters `paths` down to entries `M.exists` accepts, preserving order.
--- @param paths string[]
--- @return string[]
function M.filter_existing(paths)
	local filtered = {}
	for _, path in ipairs(paths) do
		if M.exists(path) then
			table.insert(filtered, path)
		end
	end
	return filtered
end

--- Returns the discovered stylesheets for the current buffer's project,
--- expressed as paths relative to Neovim's startup cwd (see the module-level
--- comment on `startup_cwd`), scanning at most once per project root.
--- @return string[]|nil style_sheets, boolean is_new `is_new` is true only
--- the first time (or right after `M.invalidate`) a given root is scanned.
function M.discover_for_current_buffer()
	local root = M.find_project_root()
	if not root then
		return nil, false
	end

	if root_cache[root] then
		return root_cache[root], false
	end

	local absolute = M.scan_project(root)
	local relative = {}
	for _, path in ipairs(absolute) do
		table.insert(relative, M.relpath(path, startup_cwd))
	end

	root_cache[root] = relative
	return relative, true
end

--- Clears the cached scan for the current buffer's project root, so the next
--- call to `M.discover_for_current_buffer` re-walks the import graph.
--- @return string|nil root the project root that was invalidated, if any
function M.invalidate_current()
	local root = M.find_project_root()
	if root then
		root_cache[root] = nil
	end
	return root
end

return M
