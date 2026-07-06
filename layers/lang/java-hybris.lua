local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")
local Command = commands.Command
local declarative_layer = require("LYRD.shared.declarative_layer")

-- Tracks which jdtls client IDs have already received the Hybris classpath in
-- this session so that opening multiple Java files doesn't trigger N loads.
local _applied_clients = {}

--- Environment variable names for locating Hybris and Ant installations.
local HYBRIS_HOME_ENV = "HYBRIS_HOME"
local ANT_HOME_ENV = "ANT_HOME"

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
	-- Commands specific to this layer; registered in L.settings().
	LYRDJavaHybrisLoadSolution = Command:new("Hybris: Load solution (Java)", nil, icons.folder.open),
	LYRDJavaHybrisCurrentConfig = Command:new("Hybris: Show current config", nil, icons.other.environment),
	-- Current Hybris configuration after the last load (or empty if none loaded yet).
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
	hybris_icon = "󰰳 ",
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

-- Returns the hybris installation root (the directory that contains bin/platform/).
-- HYBRIS_HOME may point to the project root (which has a hybris/ subfolder) or
-- directly to the hybris/ directory — both conventions are handled.
---@return string?
local function find_hybris_home()
	local raw = os.getenv(HYBRIS_HOME_ENV)
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

-- Reads localextensions.xml to determine which extensions are active in this
-- project. Returns a set of extension names (name → true), or nil when the
-- file is absent (callers treat nil as "include all").
---@param hybris_home string
---@return table<string, boolean>?
local function collect_active_extension_names(hybris_home)
	local path = hybris_home .. "/config/localextensions.xml"
	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end
	local active = {}
	for _, line in ipairs(vim.fn.readfile(path)) do
		local name = line:match('<extension%s+name="([^"]+)"')
		if name then
			active[name] = true
		end
	end
	return active
end

---@param hybris_home string
---@param extra_patterns string[]
---@param active_extensions table<string, boolean>?
---@return string[]
local function collect_platform_jars(hybris_home, extra_patterns, active_extensions)
	local jars = {}
	-- Platform core has a flat layout — direct globs are correct here.
	local flat_patterns = {
		hybris_home .. "/bin/platform/lib/*.jar",
		hybris_home .. "/bin/platform/bootstrap/bin/*.jar",
		hybris_home .. "/bin/platform/ext/*/lib/*.jar",
		hybris_home .. "/bin/platform/ext/*/bin/*.jar",
	}
	for _, pattern in ipairs(flat_patterns) do
		local found = vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })
		vim.list_extend(jars, found)
	end

	-- modules/ and ext-* both use extensioninfo.xml to locate extension roots.
	-- lib/ (third-party deps) is always collected. bin/ (compiled classes) is
	-- skipped for active extensions that have source (those go into sourcePaths);
	-- inactive extensions or those without source still need their bin/*.jar.
	local function collect_extension_jars(top_dir)
		for _, ext_root in ipairs(find_extension_roots(top_dir)) do
			local ext_name = vim.fn.fnamemodify(ext_root, ":t")
			local lib_jars = vim.split(vim.fn.glob(ext_root .. "/lib/*.jar"), "\n", { trimempty = true })
			vim.list_extend(jars, lib_jars)
			local is_active = active_extensions == nil or active_extensions[ext_name]
			local has_source = vim.fn.isdirectory(ext_root .. "/src") == 1
				or vim.fn.isdirectory(ext_root .. "/gensrc") == 1
			if not (is_active and has_source) then
				local bin_jars = vim.split(vim.fn.glob(ext_root .. "/bin/*.jar"), "\n", { trimempty = true })
				vim.list_extend(jars, bin_jars)
			end
		end
	end

	local module_groups = vim.split(vim.fn.glob(hybris_home .. "/bin/modules/*"), "\n", { trimempty = true })
	for _, group in ipairs(module_groups) do
		if vim.fn.isdirectory(group) == 1 then
			collect_extension_jars(group)
		end
	end

	for _, p in ipairs(extra_patterns) do
		local top_dirs = vim.split(vim.fn.glob(hybris_home .. "/bin/" .. p), "\n", { trimempty = true })
		for _, top_dir in ipairs(top_dirs) do
			if vim.fn.isdirectory(top_dir) == 1 then
				collect_extension_jars(top_dir)
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
---@param active_extensions table<string, boolean>?
---@return string[]
local function collect_source_paths(hybris_home, extra_patterns, active_extensions)
	local paths = {}
	local source_subdirs = { "src", "gensrc", "web/src" }

	-- Platform extensions (auto-loaded, not filtered by localextensions.xml).
	local platform_dir = hybris_home .. "/bin/platform/ext"
	if vim.fn.isdirectory(platform_dir) == 1 then
		for _, ext_root in ipairs(find_extension_roots(platform_dir)) do
			for _, subdir in ipairs(source_subdirs) do
				local candidate = ext_root .. "/" .. subdir
				if vim.fn.isdirectory(candidate) == 1 then
					table.insert(paths, candidate)
				end
			end
		end
	end

	-- Custom extensions (filtered by active extensions).
	local custom_dir = hybris_home .. "/bin/custom"
	if vim.fn.isdirectory(custom_dir) == 1 then
		for _, ext_root in ipairs(find_extension_roots(custom_dir)) do
			local ext_name = vim.fn.fnamemodify(ext_root, ":t")
			if active_extensions == nil or active_extensions[ext_name] then
				for _, subdir in ipairs(source_subdirs) do
					local candidate = ext_root .. "/" .. subdir
					if vim.fn.isdirectory(candidate) == 1 then
						table.insert(paths, candidate)
					end
				end
			end
		end
	end

	-- modules/ and ext-* are filtered to active extensions only.
	-- Inactive extensions still get binary JARs in referencedLibraries for
	-- dependency resolution, but their source is not indexed by JDTLS.
	local function collect_extension_sources(top_dir)
		for _, ext_root in ipairs(find_extension_roots(top_dir)) do
			local ext_name = vim.fn.fnamemodify(ext_root, ":t")
			if active_extensions == nil or active_extensions[ext_name] then
				for _, subdir in ipairs(source_subdirs) do
					local candidate = ext_root .. "/" .. subdir
					if vim.fn.isdirectory(candidate) == 1 then
						table.insert(paths, candidate)
					end
				end
			end
		end
	end

	local module_groups = vim.split(vim.fn.glob(hybris_home .. "/bin/modules/*"), "\n", { trimempty = true })
	for _, group in ipairs(module_groups) do
		if vim.fn.isdirectory(group) == 1 then
			collect_extension_sources(group)
		end
	end

	for _, p in ipairs(extra_patterns) do
		local top_dirs = vim.split(vim.fn.glob(hybris_home .. "/bin/" .. p), "\n", { trimempty = true })
		for _, top_dir in ipairs(top_dirs) do
			if vim.fn.isdirectory(top_dir) == 1 then
				collect_extension_sources(top_dir)
			end
		end
	end

	return paths
end

-- Builds the java.import.exclusions list that prevents JDTLS from treating
-- individual Hybris extensions as standalone Eclipse projects.  Without these,
-- JDTLS finds .classpath/.project files in each extension root and enters
-- Eclipse-project mode for those files, which resolves cross-extension types
-- from compiled JARs only — completely ignoring our sourcePaths configuration.
-- With the exclusions, extension directories skip Eclipse/Maven/Gradle project
-- detection and fall back to invisible-project mode, where sourcePaths applies
-- globally and source changes are visible without a rebuild.
---@param hybris_home string
---@param extra_patterns string[]
---@return string[]
local function build_import_exclusions(hybris_home, extra_patterns)
	local exclusions = {
		hybris_home .. "/bin/platform/ext/**",
		hybris_home .. "/bin/modules/**",
		hybris_home .. "/bin/custom/**",
	}
	for _, p in ipairs(extra_patterns) do
		table.insert(exclusions, hybris_home .. "/bin/" .. p .. "/**")
	end
	return exclusions
end

-- ─── Command implementation ───────────────────────────────────────────────────

local function load_hybris_solution()
	local raw_env = os.getenv(HYBRIS_HOME_ENV) or "(not set)"
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

	local active_extensions = collect_active_extension_names(hybris_home)
	local platform_jars = collect_platform_jars(hybris_home, extra, active_extensions)
	local eclipse_jars = collect_eclipse_classpath_jars(hybris_home, extra)
	local source_paths = collect_source_paths(hybris_home, extra, active_extensions)
	local import_exclusions = build_import_exclusions(hybris_home, extra)

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
					sourcePaths = unique_sources,
				},
				-- Prevent JDTLS from treating each extension as a standalone Eclipse
				-- project (via .classpath/.project files).  In Eclipse-project mode,
				-- cross-extension types are resolved from compiled JARs only and
				-- sourcePaths is ignored.  With these exclusions, extensions fall into
				-- invisible-project mode where sourcePaths applies globally.
				import = {
					exclusions = import_exclusions,
				},
			},
		},
	}

	L.current_hybris_config = {
		hybris_home = hybris_home,
		jars = unique_jars,
		source_paths = unique_sources,
		import_exclusions = import_exclusions,
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
				"Hybris: %d JARs + %d source paths sent to JDTLS.\n"
					.. "Run :LspRestart jdtls once so import exclusions take effect (needed for cross-extension source resolution).",
				#unique_jars,
				#unique_sources
			),
			vim.log.levels.WARN
		)
	else
		vim.notify(
			string.format(
				"Hybris: %d JARs + %d source paths registered.\n"
					.. "Open a Java file to start JDTLS with full Hybris configuration.",
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
	local exclusions = config.import_exclusions or {}
	local lines = {
		"HYBRIS_HOME: " .. (config.hybris_home or "(unknown)"),
		"",
		string.format("Source paths (%d):", #sources),
	}
	for _, path in ipairs(sources) do
		table.insert(lines, "  " .. path)
	end
	table.insert(lines, "")
	table.insert(lines, string.format("Import exclusions (%d):", #exclusions))
	for _, ex in ipairs(exclusions) do
		table.insert(lines, "  " .. ex)
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
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.hybris_tasks"))
end

function L.keybindings()
	local mappings = require("LYRD.layers.mappings")
	local menu_header = mappings.menu_header
	mappings.create_menu("<Space>c", {
		menu_header("h", "Hybris (SAP e-commerce)", {
			{ "l", L.LYRDJavaHybrisLoadSolution },
			{ "c", L.LYRDJavaHybrisCurrentConfig },
		}, L.hybris_icon),
	})
end

function L.complete()
	-- When jdtls attaches after a manual load has already been performed,
	-- push the pre-computed config to the new client (e.g. after LspRestart)
	-- without requiring the user to run the command again.
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("LYRDHybrisLspAttach", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client or client.name ~= "jdtls" then
				return
			end
			if _applied_clients[args.data.client_id] then
				return
			end
			_applied_clients[args.data.client_id] = true
			local config = L.current_hybris_config
			if vim.tbl_isempty(config) then
				return
			end
			vim.schedule(function()
				client:notify("workspace/didChangeConfiguration", {
					settings = {
						java = {
							import = {
								exclusions = config.import_exclusions,
							},
							project = {
								referencedLibraries = config.jars,
								sourcePaths = config.source_paths,
							},
						},
					},
				})
			end)
		end,
	})
end

function L.healthcheck()
	local health = require("LYRD.health")
	health.check_executable("ant")
	local hybris_home = find_hybris_home()
	if hybris_home then
		vim.health.ok("HYBRIS_HOME is set: " .. hybris_home)
	else
		vim.health.warn(
			"HYBRIS_HOME is not set or invalid (current: " .. (os.getenv(HYBRIS_HOME_ENV) or "not set") .. ")"
		)
	end
	local ant_home = os.getenv(ANT_HOME_ENV)
	if ant_home and ant_home ~= "" and vim.fn.isdirectory(ant_home) == 1 then
		vim.health.ok("ANT_HOME is set: " .. ant_home)
	else
		vim.health.warn("ANT_HOME is not set; Hybris ant builds may fail")
	end
end

return declarative_layer.apply(L)
