-- Hybris "Type System" index: parses every *-items.xml under a Hybris
-- installation into an in-memory model of ItemTypes/attributes/EnumTypes/
-- Relations, merged across files and inheritance. items.xml's XSD makes
-- extends=/type= bare xs:string, so ItemType-name and attribute completion
-- can only come from this parsed data index -- no XML language server can
-- provide it structurally.
--
-- Public API:
--   M.build(hybris_home, cache_key)            -- sync (re)scan; returns stats
--   M.build_async(hybris_home, cache_key, cb?)  -- chunked, non-blocking
--   M.ensure(hybris_home, cache_key, cb?, force?) -- in-memory -> disk cache -> async build
--   M.is_built()
--   M.all_types() / M.all_enums()
--   M.get_type(code)
--   M.attrs_of(code, inherited?)
--   M.find(code)                 -- declaration sites for a type/enum
--   M.find_attr(code, qualifier) -- declaration site of an attribute (walks inheritance)

local utils = require("LYRD.shared.utils")

local M = {}

-- index = {
--   types = { [lowercode] = { code, extends, declarations={{file,line}}, attrs={[lowerq]={qualifier,type,file,line}} } },
--   enums = { [lowercode] = { code, declarations={{file,line}}, values={...} } },
--   built_for = <cache_key>, files = <n>,
-- }
local index = nil

---@param path string
---@return string?
local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	return content
end

-- Fast offset->line mapper for a file's content. Naively recomputing the line
-- for every itemtype/attribute via s:sub(1,off):gsub("\n") is O(n^2) over a
-- big items.xml. Precompute newline offsets once (O(n)), then binary-search
-- per lookup.
---@param s string
---@return fun(offset: integer): integer
local function line_mapper(s)
	local newlines, i = {}, 0
	while true do
		i = s:find("\n", i + 1, true)
		if not i then
			break
		end
		table.insert(newlines, i)
	end
	return function(off)
		local lo, hi, count = 1, #newlines, 0
		while lo <= hi do
			local mid = math.floor((lo + hi) / 2)
			if newlines[mid] < off then
				count = mid
				lo = mid + 1
			else
				hi = mid - 1
			end
		end
		return count + 1
	end
end

---@param str string
---@param name string
---@return string?
local function attr(str, name)
	return str:match(name .. '%s*=%s*"([^"]*)"') or str:match(name .. "%s*=%s*'([^']*)'")
end

---@param code string
---@return table
local function ensure_type(code)
	local key = code:lower()
	local t = index.types[key]
	if not t then
		t = { code = code, declarations = {}, attrs = {} }
		index.types[key] = t
	end
	return t
end

---@param code string
---@return table
local function ensure_enum(code)
	local key = code:lower()
	local e = index.enums[key]
	if not e then
		e = { code = code, declarations = {}, values = {} }
		index.enums[key] = e
	end
	return e
end

-- Registers one attribute on a type. First declaration wins for the jump
-- target; later redeclarations are ignored for location.
---@param typecode string?
---@param qualifier string?
---@param atype string?
---@param file string
---@param line integer
local function add_attr(typecode, qualifier, atype, file, line)
	if not typecode or not qualifier then
		return
	end
	local t = ensure_type(typecode)
	local k = qualifier:lower()
	if not t.attrs[k] then
		t.attrs[k] = { qualifier = qualifier, type = atype, file = file, line = line }
	end
end

---@param content string
---@param file string
---@param lf fun(offset: integer): integer
local function parse_itemtypes(content, file, lf)
	local pos = 1
	while true do
		local s, e, tag = content:find("<itemtype%s+([^>]-)/?>", pos)
		if not s then
			break
		end
		pos = e + 1
		local code = attr(tag, "code")
		-- Self-closing (<itemtype .../>) has no attribute children and no
		-- </itemtype> to close: searching for one would scan forward to the
		-- NEXT </itemtype> anywhere later in the file (or EOF if none exists),
		-- silently skipping every itemtype declared in between. Only look for
		-- a closing tag / scan attributes when this one actually isn't
		-- self-closing.
		local self_closing = content:sub(e - 1, e - 1) == "/"
		if code then
			local extends = attr(tag, "extends")
			local t = ensure_type(code)
			if extends and not t.extends then
				t.extends = extends
			end
			table.insert(t.declarations, { file = file, line = lf(s) })

			if not self_closing then
				-- Attributes live between this <itemtype ...> and its
				-- </itemtype> (itemtypes are never nested). Slice that block
				-- and scan <attribute ...> inside it.
				local close = content:find("</itemtype>", e) or #content
				local apos = e
				while true do
					local as, ae, atag = content:find("<attribute%s+([^>]-)/?>", apos)
					if not as or as > close then
						break
					end
					apos = ae + 1
					add_attr(code, attr(atag, "qualifier"), attr(atag, "type"), file, lf(as))
				end
				pos = math.max(pos, close)
			end
		end
	end
end

---@param content string
---@param file string
---@param lf fun(offset: integer): integer
local function parse_enumtypes(content, file, lf)
	local pos = 1
	while true do
		local s, e, tag = content:find("<enumtype%s+([^>]-)/?>", pos)
		if not s then
			break
		end
		pos = e + 1
		local code = attr(tag, "code")
		local self_closing = content:sub(e - 1, e - 1) == "/"
		if code then
			local en = ensure_enum(code)
			table.insert(en.declarations, { file = file, line = lf(s) })
			if not self_closing then
				local close = content:find("</enumtype>", e) or #content
				local vpos = e
				while true do
					local vs, ve, vtag = content:find("<value%s+([^>]-)/?>", vpos)
					if not vs or vs > close then
						break
					end
					vpos = ve + 1
					local vcode = attr(vtag, "code")
					if vcode then
						table.insert(en.values, vcode)
					end
				end
				pos = math.max(pos, close)
			end
		end
	end
end

-- Relations add a navigable qualifier to each end's item type (each side
-- exposes the OTHER end's qualifier), so they must appear in attribute
-- completion even though they're never declared as an <attribute> tag.
---@param content string
---@param file string
---@param lf fun(offset: integer): integer
local function parse_relations(content, file, lf)
	local pos = 1
	while true do
		local s, e = content:find("<relation%s+[^>]->", pos)
		if not s then
			break
		end
		pos = e + 1
		-- Self-closing <relation .../> has no sourceElement/targetElement
		-- children -- same forward-scan-to-EOF hazard as itemtype/enumtype
		-- above, and never happens in real relation declarations, but skip
		-- defensively rather than searching for a </relation> that isn't there.
		if content:sub(e - 1, e - 1) ~= "/" then
			local close = content:find("</relation>", e) or #content
			local block = content:sub(e, close)
			local src = block:match("<sourceElement%s+([^>]->)") or block:match("<sourceElement%s+([^>]-/>)")
			local tgt = block:match("<targetElement%s+([^>]->)") or block:match("<targetElement%s+([^>]-/>)")
			local sline = lf(s)
			if src and tgt then
				local sq, st = attr(src, "qualifier"), attr(src, "type")
				local tq, tt = attr(tgt, "qualifier"), attr(tgt, "type")
				-- source type gets the target qualifier; target type gets the source qualifier.
				if st and tq then
					add_attr(st, tq, tt, file, sline)
				end
				if tt and sq then
					add_attr(tt, sq, st, file, sline)
				end
			end
			pos = math.max(pos, close)
		end
	end
end

-- Finds every *-items.xml under <hybris_home>/bin. Prefers `fd`, falls back
-- to vim.fs.find. No pruning/skip-dirs needed here (unlike scanner.lua's
-- extensioninfo.xml discovery) -- items.xml files are far fewer and don't
-- risk the same nesting cost.
---@param hybris_home string
---@return string[]
local function find_items_xml(hybris_home)
	local bin = hybris_home .. "/bin"
	if vim.fn.executable("fd") == 1 then
		local results = vim.fn.systemlist({ "fd", "-L", "-t", "f", "-a", "--", "items\\.xml$", bin })
		if vim.v.shell_error == 0 and #results > 0 then
			return results
		end
	end
	return vim.fs.find(function(name)
		return name:match("items%.xml$") ~= nil
	end, { path = bin, type = "file", limit = math.huge })
end

---@param path string
local function parse_one(path)
	local content = read_file(path)
	if not content then
		return
	end
	content = content:gsub("<!%-%-.-%-%->", "") -- strip comments (avoid commented-out types)
	local resolved = vim.fn.resolve(path)
	local lf = line_mapper(content)
	parse_itemtypes(content, resolved, lf)
	parse_enumtypes(content, resolved, lf)
	parse_relations(content, resolved, lf)
end

---@return table
local function stats()
	return { files = index.files, types = vim.tbl_count(index.types), enums = vim.tbl_count(index.enums) }
end

-- ─── Disk cache (instant reload across sessions) ───────────────────────────
-- Keyed by project root (same hashing scheme as shared/hybris/store.lua and
-- runtime/lsp/jdtls.lua), NOT by hybris_home -- consistent with the earlier
-- decision that Hybris caches are per-Neovim-project. Lives under
-- stdpath("cache") rather than store.lua's stdpath("data"): this index is a
-- disposable, rebuildable-from-source cache, not user-authored config.
---@param cache_key string
---@return string
local function hash_cache_key(cache_key)
	local normalized = vim.fn.fnamemodify(cache_key, ":p:h")
	return (normalized:gsub("[/\\:+-]", "_"))
end

---@param cache_key string
---@return string
local function cache_path(cache_key)
	local dir = utils.join_paths(vim.fn.stdpath("cache"), "lyrd", "hybris-types")
	vim.fn.mkdir(dir, "p")
	return utils.join_paths(dir, hash_cache_key(cache_key) .. ".json")
end

---@param cache_key string
local function save_cache(cache_key)
	local ok, encoded = pcall(vim.json.encode, { types = index.types, enums = index.enums, files = index.files })
	if ok then
		pcall(vim.fn.writefile, { encoded }, cache_path(cache_key))
	end
end

---@param cache_key string
---@return boolean
local function load_cache(cache_key)
	local path = cache_path(cache_key)
	if vim.fn.filereadable(path) == 0 then
		return false
	end
	local ok, data = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	end)
	if not ok or type(data) ~= "table" or not data.types then
		return false
	end
	index = { types = data.types, enums = data.enums or {}, built_for = cache_key, files = data.files or 0 }
	return true
end

-- Synchronous build (used for :LYRDJavaHybrisReindexTypes / tests). Writes
-- the disk cache.
---@param hybris_home string
---@param cache_key string
---@return table stats
function M.build(hybris_home, cache_key)
	index = { types = {}, enums = {}, built_for = cache_key, files = 0 }
	local files = find_items_xml(hybris_home)
	for _, path in ipairs(files) do
		parse_one(path)
	end
	index.files = #files
	save_cache(cache_key)
	return stats()
end

-- Chunked async build: parses ~20 files per scheduled tick so the UI never
-- freezes during a large scan. on_done(stats) fires once complete.
---@param hybris_home string
---@param cache_key string
---@param on_done fun(stats: table)?
function M.build_async(hybris_home, cache_key, on_done)
	index = { types = {}, enums = {}, built_for = cache_key, files = 0, building = true }
	local files = find_items_xml(hybris_home)
	local i = 0
	local function step()
		local stop = math.min(i + 20, #files)
		while i < stop do
			i = i + 1
			parse_one(files[i])
		end
		if i < #files then
			vim.schedule(step)
		else
			index.files = #files
			index.building = false
			save_cache(cache_key)
			if on_done then
				on_done(stats())
			end
		end
	end
	vim.schedule(step)
end

-- Makes the index available. Order: in-memory -> disk cache (instant) ->
-- async build. on_ready(stats|nil) fires once usable. force=true bypasses
-- the cache and rebuilds.
---@param hybris_home string
---@param cache_key string
---@param on_ready fun(stats: table)?
---@param force boolean?
---@return table index
function M.ensure(hybris_home, cache_key, on_ready, force)
	if not force and index and index.built_for == cache_key and not index.building then
		if on_ready then
			on_ready(stats())
		end
		return index
	end
	if not force and (not index or index.built_for ~= cache_key) and load_cache(cache_key) then
		if on_ready then
			on_ready(stats())
		end
		return index
	end
	if index and index.building then
		return index -- a build is already in flight
	end
	M.build_async(hybris_home, cache_key, on_ready)
	return index
end

---@return boolean
function M.is_built()
	return index ~= nil and not index.building
end

---@return table[]
function M.all_types()
	local out = {}
	if not index then
		return out
	end
	for _, t in pairs(index.types) do
		local d = t.declarations[1]
		table.insert(out, { code = t.code, extends = t.extends, file = d and d.file, line = d and d.line })
	end
	table.sort(out, function(a, b)
		return a.code < b.code
	end)
	return out
end

---@return table[]
function M.all_enums()
	local out = {}
	if not index then
		return out
	end
	for _, e in pairs(index.enums) do
		local d = e.declarations[1]
		table.insert(out, { code = e.code, file = d and d.file, line = d and d.line, values = e.values })
	end
	table.sort(out, function(a, b)
		return a.code < b.code
	end)
	return out
end

---@param code string?
---@return table?
function M.get_type(code)
	if not index or not code then
		return nil
	end
	return index.types[code:lower()]
end

-- Merged attribute list. With `inherited`, walks the extends chain (default
-- parent GenericItem) and unions parent attributes; child wins on qualifier
-- collisions.
---@param code string?
---@param inherited boolean?
---@return table[]
function M.attrs_of(code, inherited)
	if not index or not code then
		return {}
	end
	local seen, out = {}, {}
	local cur, guard = code, 0
	while cur and guard < 50 do
		guard = guard + 1
		local t = index.types[cur:lower()]
		if not t then
			break
		end
		for k, a in pairs(t.attrs) do
			if not seen[k] then
				seen[k] = true
				table.insert(out, a)
			end
		end
		if not inherited then
			break
		end
		cur = t.extends -- walk up; the root type has no extends, so the loop ends
	end
	table.sort(out, function(a, b)
		return a.qualifier < b.qualifier
	end)
	return out
end

-- Declaration sites (multiple) for a type OR enum code.
---@param code string?
---@return table[]
function M.find(code)
	if not index or not code then
		return {}
	end
	local t = index.types[code:lower()]
	if t then
		return t.declarations
	end
	local e = index.enums[code:lower()]
	if e then
		return e.declarations
	end
	return {}
end

-- Declaration site of an attribute on `code` (walks inheritance).
---@param code string?
---@param qualifier string?
---@return table?
function M.find_attr(code, qualifier)
	if not index or not code or not qualifier then
		return nil
	end
	local cur, guard = code, 0
	while cur and guard < 50 do
		guard = guard + 1
		local t = index.types[cur:lower()]
		if not t then
			return nil
		end
		local a = t.attrs[qualifier:lower()]
		if a then
			return { file = a.file, line = a.line }
		end
		cur = t.extends
	end
	return nil
end

return M
