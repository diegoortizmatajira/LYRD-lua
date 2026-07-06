local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")
local Command = commands.Command
local declarative_layer = require("LYRD.shared.declarative_layer")
local resolver = require("LYRD.shared.hybris.resolver")
local scanner = require("LYRD.shared.hybris.scanner")
local store = require("LYRD.shared.hybris.store")

-- Tracks which jdtls client IDs have already received the Hybris classpath in
-- this session so that opening multiple Java files doesn't trigger N loads.
local _applied_clients = {}

--- Environment variable name for locating the Ant installation.
local ANT_HOME_ENV = "ANT_HOME"

---@type table|LYRD.shared.setup.DeclarativeLayer
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
	LYRDJavaHybrisImportSolution = Command:new("Hybris: Import solution (Java)", nil, icons.action.import),
	LYRDJavaHybrisLoadSolution = Command:new("Hybris: Load solution (Java)", nil, icons.folder.open),
	LYRDJavaHybrisConfigureSolution = Command:new("Hybris: Configure solution (Java)", nil, icons.other.wrench),
	LYRDJavaHybrisCurrentConfig = Command:new("Hybris: Show current config", nil, icons.other.environment),
	LYRDJavaHybrisOpenConfigFile = Command:new("Hybris: Open solution config file", nil, icons.file.default),
	-- Full solution config (per-extension jars/sources + independent jars) from
	-- the last Import/Reload/Configure-save, or empty if none applied yet.
	-- @type table<string, any>?
	current_hybris_config = {},
	-- Last JDTLS settings payload built from current_hybris_config; re-sent to
	-- newly attached jdtls clients (see L.complete()).
	-- @type table?
	current_resolved_settings = nil,
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

---@return string
local function project_root()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
end

---@param resolved LYRD.hybris.Resolved
---@return boolean
local function exclusions_changed(resolved)
	local previous = L.current_resolved_settings and L.current_resolved_settings.settings.java.import.exclusions
	if not previous then
		return true
	end
	return table.concat(previous, "\n") ~= table.concat(resolved.import_exclusions, "\n")
end

-- Resolves `config` into JDTLS settings, persists it for future jdtls starts,
-- and pushes a live update to any already-running jdtls client. Shared by
-- Import, Reload, and Configure-save.
---@param config table
local function apply_config(config)
	local resolved = resolver.resolve(config)
	local settings = resolver.to_jdtls_settings(resolved)
	local restart_needed = exclusions_changed(resolved)

	-- Persist for future jdtls starts (picked up on next vim.lsp.start()).
	vim.lsp.config("jdtls", settings)

	-- Push the update directly to any running jdtls client via the LSP
	-- workspace/didChangeConfiguration notification -- no restart required for
	-- jars/sourcePaths; import.exclusions changes still need one.
	local clients = vim.lsp.get_clients({ name = "jdtls" })
	if #clients > 0 then
		for _, client in ipairs(clients) do
			client:notify("workspace/didChangeConfiguration", settings)
		end
		if restart_needed then
			vim.notify(
				string.format(
					"Hybris: %d JARs + %d source paths sent to JDTLS.\n"
						.. "Run :LspRestart jdtls once so import exclusions take effect (needed for cross-extension source resolution).",
					#resolved.referencedLibraries,
					#resolved.sourcePaths
				),
				vim.log.levels.WARN
			)
		else
			vim.notify(
				string.format(
					"Hybris: %d JARs + %d source paths applied.",
					#resolved.referencedLibraries,
					#resolved.sourcePaths
				),
				vim.log.levels.INFO
			)
		end
	else
		vim.notify(
			string.format(
				"Hybris: %d JARs + %d source paths registered.\n"
					.. "Open a Java file to start JDTLS with full Hybris configuration.",
				#resolved.referencedLibraries,
				#resolved.sourcePaths
			),
			vim.log.levels.INFO
		)
	end

	L.current_resolved_settings = settings
end

---@param root string
---@return fun(updated_config: table)
local function make_save_handler(root)
	return function(updated_config)
		store.save(root, updated_config)
		L.current_hybris_config = updated_config
		apply_config(updated_config)
	end
end

-- ─── Command implementations ───────────────────────────────────────────────

local function import_solution()
	local hybris_home = scanner.find_hybris_home()
	if not hybris_home then
		local raw_env = os.getenv("HYBRIS_HOME") or "(not set)"
		vim.notify(
			"Hybris: HYBRIS_HOME is not set or points to an invalid directory.\n"
				.. "Current value: "
				.. raw_env
				.. "\nSet HYBRIS_HOME to the Hybris installation root and try again.",
			vim.log.levels.ERROR
		)
		return
	end

	local root = project_root()
	if store.exists(root) then
		local choice = vim.fn.confirm(
			"Hybris: a cached solution already exists for this project.\n"
				.. "Re-importing rescans the filesystem and resets any extension/jar toggles.\n\nContinue?",
			"&Yes\n&No",
			2
		)
		if choice ~= 1 then
			return
		end
	end

	local extra = L.custom_ext_patterns
	local extra_label = #extra > 0 and (" + custom: " .. table.concat(extra, ", ")) or ""
	vim.notify("Hybris: scanning " .. hybris_home .. extra_label .. " …", vim.log.levels.INFO)

	local scanned = scanner.scan(hybris_home, extra)
	local config = {
		version = 1,
		hybris_home = hybris_home,
		project_root = root,
		scanned_at = os.time(),
		custom_ext_patterns = vim.deepcopy(extra),
		extensions = scanned.extensions,
		independent_jars = scanned.independent_jars,
		import_exclusions = scanned.import_exclusions,
	}

	store.save(root, config)
	L.current_hybris_config = config
	apply_config(config)

	require("LYRD.shared.ui.hybris_solution").show(config, { on_save = make_save_handler(root) })
end

local function reload_solution()
	local root = project_root()
	local config = store.load(root)
	if not config then
		vim.notify(
			"Hybris: no cached solution for this project. Run :LYRDJavaHybrisImportSolution first.",
			vim.log.levels.WARN
		)
		return
	end
	L.current_hybris_config = config
	apply_config(config)
end

local function configure_solution()
	local root = project_root()
	local config = store.load(root)
	if not config then
		vim.notify(
			"Hybris: no cached solution for this project. Run :LYRDJavaHybrisImportSolution first.",
			vim.log.levels.WARN
		)
		return
	end
	require("LYRD.shared.ui.hybris_solution").show(config, { on_save = make_save_handler(root) })
end

local function open_config_file()
	local root = project_root()
	local path = store.cache_path(root)
	if vim.fn.filereadable(path) ~= 1 then
		vim.notify(
			"Hybris: no cached solution for this project. Run :LYRDJavaHybrisImportSolution first.",
			vim.log.levels.WARN
		)
		return
	end
	vim.cmd.edit(vim.fn.fnameescape(path))
end

local function show_current_config()
	local config = L.current_hybris_config
	if vim.tbl_isempty(config) then
		vim.notify("Hybris: no config loaded yet. Run :LYRDJavaHybrisImportSolution first.", vim.log.levels.WARN)
		return
	end

	local resolved = resolver.resolve(config)
	local lines = {
		"HYBRIS_HOME: " .. (config.hybris_home or "(unknown)"),
		"",
		string.format("Source paths (%d):", #resolved.sourcePaths),
	}
	for _, path in ipairs(resolved.sourcePaths) do
		table.insert(lines, "  " .. path)
	end
	table.insert(lines, "")
	table.insert(lines, string.format("Import exclusions (%d):", #resolved.import_exclusions))
	for _, ex in ipairs(resolved.import_exclusions) do
		table.insert(lines, "  " .. ex)
	end
	table.insert(lines, "")
	table.insert(lines, string.format("JARs (%d):", #resolved.referencedLibraries))
	for _, jar in ipairs(resolved.referencedLibraries) do
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
		LYRDJavaHybrisImportSolution = L.LYRDJavaHybrisImportSolution,
		LYRDJavaHybrisReloadSolution = L.LYRDJavaHybrisLoadSolution,
		LYRDJavaHybrisConfigureSolution = L.LYRDJavaHybrisConfigureSolution,
		LYRDJavaHybrisCurrentConfig = L.LYRDJavaHybrisCurrentConfig,
		LYRDJavaHybrisOpenConfigFile = L.LYRDJavaHybrisOpenConfigFile,
	})
	commands.implement("*", {
		{ L.LYRDJavaHybrisImportSolution, import_solution },
		{ L.LYRDJavaHybrisLoadSolution, reload_solution },
		{ L.LYRDJavaHybrisConfigureSolution, configure_solution },
		{ L.LYRDJavaHybrisCurrentConfig, show_current_config },
		{ L.LYRDJavaHybrisOpenConfigFile, open_config_file },
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
			{ "i", L.LYRDJavaHybrisImportSolution },
			{ "l", L.LYRDJavaHybrisLoadSolution },
			{ "s", L.LYRDJavaHybrisConfigureSolution },
			{ "c", L.LYRDJavaHybrisCurrentConfig },
			{ "o", L.LYRDJavaHybrisOpenConfigFile },
		}, L.hybris_icon),
	})
end

function L.complete()
	-- When jdtls attaches after Import/Reload/Configure-save already computed a
	-- config this session, push it to the new client (e.g. after LspRestart)
	-- without requiring the user to re-run the command.
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
			if not L.current_resolved_settings then
				return
			end
			vim.schedule(function()
				client:notify("workspace/didChangeConfiguration", L.current_resolved_settings)
			end)
		end,
	})
end

function L.healthcheck()
	local health = require("LYRD.health")
	health.check_executable("ant")
	local hybris_home = scanner.find_hybris_home()
	if hybris_home then
		vim.health.ok("HYBRIS_HOME is set: " .. hybris_home)
	else
		vim.health.warn(
			"HYBRIS_HOME is not set or invalid (current: " .. (os.getenv("HYBRIS_HOME") or "not set") .. ")"
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
