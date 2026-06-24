local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")
local Command = commands.Command
local declarative_layer = require("LYRD.shared.declarative_layer")

-- Tracks which jdtls client IDs have already received the Hybris classpath in
-- this session so that opening multiple Java files doesn't trigger N loads.
local _applied_clients = {}

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Java - Hybris (SAP Commerce) support",
	required_plugins = {},
	required_mason_packages = {},
	required_treesitter_parsers = {},
	required_enabled_lsp_servers = {},
	required_executables = {},
	required_formatters = {},
	required_formatter_per_filetype = {},
	required_test_adapters = {},
	required_null_ls_sources = {},
	required_filetype_definitions = {},
	LYRDJavaHybrisLoadSolution = Command:new("Hybris: Load solution (Java)", nil, icons.folder.open),
	LYRDJavaHybrisCurrentConfig = Command:new("Hybris: Show current config", nil, icons.other.environment),
	-- @type table<string, any>?
	current_hybris_config = {},
	-- Glob patterns relative to $HYBRIS_HOME/bin/ for non-standard extension
	-- directories. Each entry is expanded into lib/ and bin/ JAR scans and a
	-- .classpath scan (when Eclipse project files exist).
	-- Examples:
	--   { "ext-company" }          -- single known folder
	--   { "ext-*" }               -- all folders matching ext-*
	--   { "ext-company", "addons" } -- multiple explicit folders
	custom_ext_patterns = {
		"ext-*", -- default: all ext-* folders
	},
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

-- Returns the hybris installation root (the directory that contains bin/platform/).
-- HYBRIS_HOME may point to the project root (which has a hybris/ subfolder) or
-- directly to the hybris/ directory — both conventions are handled.
---@return string?
local function find_hybris_home()
	local raw = os.getenv("HYBRIS_HOME")
	if not raw or raw == "" then
		return nil
	end
	-- Convention 1: HYBRIS_HOME = <project>/hybris/  (bin/platform directly inside)
	if vim.fn.isdirectory(raw .. "/bin/platform") == 1 then
		return raw
	end
	-- Convention 2: HYBRIS_HOME = <project root>  (hybris/ is a subdirectory)
	local with_sub = raw .. "/hybris"
	if vim.fn.isdirectory(with_sub .. "/bin/platform") == 1 then
		return with_sub
	end
	-- HYBRIS_HOME is set but doesn't match either convention; return raw so the
	-- caller can show a meaningful error with the resolved path.
	if vim.fn.isdirectory(raw) == 1 then
		return raw
	end
	return nil
end

-- Locates all Hybris extension root directories inside base_dir by finding
-- extensioninfo.xml files at any nesting depth (handles group folders like
-- bin/ext-company/group/extname/ where the extension is 3 levels deep).
---@param base_dir string
---@return string[]
local function find_extension_roots(base_dir)
	local roots = {}
	local ext_infos = vim.split(vim.fn.glob(base_dir .. "/**/extensioninfo.xml"), "\n", { trimempty = true })
	for _, ext_info in ipairs(ext_infos) do
		table.insert(roots, vim.fn.fnamemodify(ext_info, ":h"))
	end
	return roots
end

---@param hybris_home string
---@param extra_patterns string[]
---@return string[]
local function collect_platform_jars(hybris_home, extra_patterns)
	local jars = {}
	-- Platform and modules have flat layout — direct globs work.
	local patterns = {
		hybris_home .. "/bin/platform/lib/*.jar",
		hybris_home .. "/bin/platform/bootstrap/bin/*.jar",
		hybris_home .. "/bin/platform/ext/*/lib/*.jar",
		hybris_home .. "/bin/platform/ext/*/bin/*.jar",
		hybris_home .. "/bin/modules/*/lib/*.jar",
		hybris_home .. "/bin/modules/*/bin/*.jar",
	}
	for _, pattern in ipairs(patterns) do
		local found = vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })
		vim.list_extend(jars, found)
	end
	-- ext-* custom folders: only collect lib/ (third-party deps). Their own
	-- compiled bin/*.jar is excluded because source is provided via sourcePaths —
	-- supplying both causes JDTLS to resolve from binary instead of source.
	for _, p in ipairs(extra_patterns) do
		local top_dirs = vim.split(vim.fn.glob(hybris_home .. "/bin/" .. p), "\n", { trimempty = true })
		for _, top_dir in ipairs(top_dirs) do
			if vim.fn.isdirectory(top_dir) == 1 then
				for _, ext_root in ipairs(find_extension_roots(top_dir)) do
					local lib_jars = vim.split(vim.fn.glob(ext_root .. "/lib/*.jar"), "\n", { trimempty = true })
					vim.list_extend(jars, lib_jars)
				end
			end
		end
	end
	return jars
end

---@param hybris_home string
---@param extra_patterns string[]
---@return string[]
local function collect_eclipse_classpath_jars(hybris_home, extra_patterns)
	local jars = {}
	local roots = { hybris_home .. "/bin/custom" }
	for _, p in ipairs(extra_patterns) do
		-- glob expands wildcards (e.g. ext-*) into concrete directories
		local dirs = vim.split(vim.fn.glob(hybris_home .. "/bin/" .. p), "\n", { trimempty = true })
		vim.list_extend(roots, dirs)
	end
	for _, root in ipairs(roots) do
		local classpath_files = vim.split(vim.fn.glob(root .. "/**/.classpath"), "\n", { trimempty = true })
		for _, cp_file in ipairs(classpath_files) do
			local lines = vim.fn.readfile(cp_file)
			for _, line in ipairs(lines) do
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
	end
	return jars
end

---@param paths string[]
---@return string[]
local function deduplicate_paths(paths)
	local seen = {}
	local result = {}
	for _, p in ipairs(paths) do
		local norm = vim.fn.fnamemodify(p, ":p")
		if not seen[norm] then
			seen[norm] = true
			table.insert(result, norm)
		end
	end
	return result
end

-- Collects src/, gensrc/, and web/src/ directories for JDTLS sourcePaths so it
-- can resolve cross-extension type references from source.
-- Platform extensions have a flat layout (bin/platform/ext/<name>/src/).
-- ext-* custom folders may nest extensions arbitrarily deep; extensioninfo.xml
-- marks each actual extension root regardless of depth.
---@param hybris_home string
---@param extra_patterns string[]
---@return string[]
local function collect_source_paths(hybris_home, extra_patterns)
	local paths = {}
	local source_subdirs = { "src", "gensrc", "web/src" }

	-- Platform and standard custom/ are always flat — direct glob is sufficient.
	local flat_patterns = {
		hybris_home .. "/bin/platform/ext/*/src",
		hybris_home .. "/bin/platform/ext/*/gensrc",
		hybris_home .. "/bin/custom/*/src",
		hybris_home .. "/bin/custom/*/gensrc",
	}
	for _, pattern in ipairs(flat_patterns) do
		local found = vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })
		for _, dir in ipairs(found) do
			if vim.fn.isdirectory(dir) == 1 then
				table.insert(paths, dir)
			end
		end
	end

	-- ext-* custom folders: use extensioninfo.xml to find extension roots at any depth.
	for _, p in ipairs(extra_patterns) do
		local top_dirs = vim.split(vim.fn.glob(hybris_home .. "/bin/" .. p), "\n", { trimempty = true })
		for _, top_dir in ipairs(top_dirs) do
			if vim.fn.isdirectory(top_dir) == 1 then
				for _, ext_root in ipairs(find_extension_roots(top_dir)) do
					for _, subdir in ipairs(source_subdirs) do
						local candidate = ext_root .. "/" .. subdir
						if vim.fn.isdirectory(candidate) == 1 then
							table.insert(paths, candidate)
						end
					end
				end
			end
		end
	end

	return paths
end

-- ─── Command implementation ───────────────────────────────────────────────────

local function load_hybris_solution()
	local raw_env = os.getenv("HYBRIS_HOME") or "(not set)"
	local hybris_home = find_hybris_home()

	if not hybris_home then
		vim.notify(
			"Hybris: HYBRIS_HOME is not set or points to an invalid directory.\n"
				.. "Current value: "
				.. raw_env
				.. "\nSet HYBRIS_HOME to the Hybris installation root and try again.",
			vim.log.levels.ERROR
		)
		return
	end

	local extra = L.custom_ext_patterns
	local extra_label = #extra > 0 and (" + custom: " .. table.concat(extra, ", ")) or ""
	vim.notify("Hybris: scanning " .. hybris_home .. extra_label .. " …", vim.log.levels.INFO)

	local platform_jars = collect_platform_jars(hybris_home, extra)
	local eclipse_jars = collect_eclipse_classpath_jars(hybris_home, extra)
	local source_paths = collect_source_paths(hybris_home, extra)

	local all_jars = {}
	vim.list_extend(all_jars, platform_jars)
	vim.list_extend(all_jars, eclipse_jars)
	local unique_jars = deduplicate_paths(all_jars)
	local unique_sources = deduplicate_paths(source_paths)

	vim.notify(
		string.format("Hybris: found %d JARs and %d source directories.", #unique_jars, #unique_sources),
		vim.log.levels.INFO
	)

	local java_settings = {
		settings = {
			java = {
				project = {
					referencedLibraries = unique_jars,
					-- Source directories of platform and custom extensions so JDTLS
					-- can resolve cross-extension type references from source code.
					sourcePaths = unique_sources,
				},
			},
		},
	}

	L.current_hybris_config = {
		hybris_home = hybris_home,
		jars = unique_jars,
		source_paths = unique_sources,
	}

	-- Persist for future jdtls starts (picked up on next vim.lsp.start()).
	vim.lsp.config("jdtls", java_settings)

	-- Push the update directly to any running jdtls client via the LSP
	-- workspace/didChangeConfiguration notification — no restart required.
	local clients = vim.lsp.get_clients({ name = "jdtls" })
	if #clients > 0 then
		for _, client in ipairs(clients) do
			client:notify("workspace/didChangeConfiguration", java_settings)
		end
		vim.notify(
			string.format(
				"Hybris: %d JARs + %d source paths sent to JDTLS. Indexing in background.",
				#unique_jars,
				#unique_sources
			),
			vim.log.levels.INFO
		)
	else
		vim.notify(
			string.format(
				"Hybris: %d JARs + %d source paths registered. Open a Java file to start JDTLS.",
				#unique_jars,
				#unique_sources
			),
			vim.log.levels.INFO
		)
	end
end

local function show_hybris_config()
	local config = L.current_hybris_config
	if vim.tbl_isempty(config) then
		vim.notify("Hybris: no config loaded yet. Run LYRDJavaHybrisLoadSolution first.", vim.log.levels.WARN)
		return
	end

	local jars = config.jars or {}
	local sources = config.source_paths or {}
	local lines = {
		"HYBRIS_HOME: " .. (config.hybris_home or "(unknown)"),
		"",
		string.format("Source paths (%d):", #sources),
	}
	for _, path in ipairs(sources) do
		table.insert(lines, "  " .. path)
	end
	table.insert(lines, "")
	table.insert(lines, string.format("JARs (%d):", #jars))
	for _, jar in ipairs(jars) do
		table.insert(lines, "  " .. jar)
	end

	local buf_name = "Hybris Config"
	local existing = vim.fn.bufnr(buf_name)
	if existing ~= -1 then
		vim.api.nvim_buf_delete(existing, { force = true })
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, buf_name)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.keymap.set("n", "q", "<cmd>bwipeout<cr>", { buffer = buf, silent = true })

	vim.cmd("split")
	vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
end

-- ─── Layer lifecycle ──────────────────────────────────────────────────────────

function L.settings()
	commands.register({
		LYRDJavaHybrisLoadSolution = L.LYRDJavaHybrisLoadSolution,
		LYRDJavaHybrisCurrentConfig = L.LYRDJavaHybrisCurrentConfig,
	})
	commands.implement("*", {
		{ L.LYRDJavaHybrisLoadSolution, load_hybris_solution },
		{ L.LYRDJavaHybrisCurrentConfig, show_hybris_config },
	})
end

function L.keybindings()
	local mappings = require("LYRD.layers.mappings")
	mappings.keys({
		{ "n", "<Space>cH", L.LYRDJavaHybrisLoadSolution },
		{ "n", "<Space>ch", L.LYRDJavaHybrisCurrentConfig },
	})
end

function L.complete()
	-- Auto-push the Hybris classpath each time jdtls attaches to a buffer.
	-- vim.schedule defers until after the LSP handshake so the server is ready
	-- to process workspace/didChangeConfiguration.
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("LYRDHybrisLspAttach", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client or client.name ~= "jdtls" then
				return
			end
			if _applied_clients[args.data.client_id] or not find_hybris_home() then
				return
			end
			_applied_clients[args.data.client_id] = true
			vim.schedule(load_hybris_solution)
		end,
	})
end

function L.healthcheck()
	local hybris_home = find_hybris_home()
	if hybris_home then
		vim.health.ok("HYBRIS_HOME is set: " .. hybris_home)
	else
		vim.health.warn(
			"HYBRIS_HOME is not set or invalid (current: " .. (os.getenv("HYBRIS_HOME") or "not set") .. ")"
		)
	end
	local ant_home = os.getenv("ANT_HOME")
	if ant_home and ant_home ~= "" and vim.fn.isdirectory(ant_home) == 1 then
		vim.health.ok("ANT_HOME is set: " .. ant_home)
	else
		vim.health.warn("ANT_HOME is not set; Hybris ant builds may fail")
	end
end

return declarative_layer.apply(L)
