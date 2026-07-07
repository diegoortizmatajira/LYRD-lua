local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")
local Command = commands.Command
local dap_hybris = require("LYRD.shared.dap.java-hybris")
local declarative_layer = require("LYRD.shared.declarative_layer")
local resolver = require("LYRD.shared.hybris.resolver")
local scanner = require("LYRD.shared.hybris.scanner")
local store = require("LYRD.shared.hybris.store")
local types = require("LYRD.shared.hybris.types")

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
	required_filetype_definitions = {
		extension = { impex = "impex" },
	},
	-- Commands specific to this layer; registered in L.settings().
	LYRDJavaHybrisImportSolution = Command:new("Hybris: Import solution (Java)", nil, icons.action.import),
	LYRDJavaHybrisLoadSolution = Command:new("Hybris: Load solution (Java)", nil, icons.folder.open),
	LYRDJavaHybrisConfigureSolution = Command:new("Hybris: Configure solution (Java)", nil, icons.other.wrench),
	LYRDJavaHybrisCurrentConfig = Command:new("Hybris: Show current config", nil, icons.other.environment),
	LYRDJavaHybrisOpenConfigFile = Command:new("Hybris: Open solution config file", nil, icons.file.default),
	-- ICON NEEDED: pick a debug/attach icon for this one (e.g. a "plug"/"bug" glyph).
	LYRDJavaHybrisAttachDebugger = Command:new("Hybris: Attach debugger (remote JVM)", nil, nil),
	-- ICON NEEDED for the next two (Type System: find/reindex).
	LYRDJavaHybrisFindType = Command:new("Hybris: Find ItemType", nil, nil),
	LYRDJavaHybrisReindexTypes = Command:new("Hybris: Reindex types (items.xml)", nil, nil),
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
-- Import, Reload, Configure-save, and the silent startup preload.
---@param config table
---@param opts { silent: boolean }?
local function apply_config(config, opts)
	local silent = opts and opts.silent
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
		if not silent then
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
		end
	elseif not silent then
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

-- Silently loads the cached solution config (if any) and merges it into
-- vim.lsp.config("jdtls", ...) BEFORE jdtls's first start this session --
-- called from L.complete()'s VimEnter handler, ahead of both the native
-- FileType autostart and our own warm-start. Without this, the first jdtls
-- boot has no Hybris settings at all and has to reconcile a completely
-- different sourcePaths/exclusions set later (whenever Reload/Import/a
-- Configure-save runs), which is the more fragile "hot update an
-- already-initialized project" path -- exactly the case warm-starting jdtls
-- early was meant to avoid.
local function preload_cached_config()
	local config = store.load(project_root())
	if not config then
		return
	end
	L.current_hybris_config = config
	apply_config(config, { silent = true })
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

local function attach_debugger()
	dap_hybris.attach_hybris()
end

-- ─── Type System (items.xml/ImpEx completion + navigation) ─────────────────

---@param file string?
---@param line integer?
local function jump_to_declaration(file, line)
	if not file then
		return
	end
	vim.cmd.edit(vim.fn.fnameescape(file))
	pcall(vim.api.nvim_win_set_cursor, 0, { line or 1, 0 })
	vim.cmd("normal! zz")
end

-- Go-to-definition for the ItemType/EnumType under the cursor. Bound
-- buffer-locally on items.xml/impex buffers (see L.complete()).
local function goto_type_definition()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end
	local decls = types.find(word)
	if #decls == 0 then
		vim.notify('Hybris: no type/enum named "' .. word .. '"', vim.log.levels.INFO)
		return
	end
	jump_to_declaration(decls[1].file, decls[1].line)
	if #decls > 1 then
		vim.notify(
			string.format('Hybris: "%s" declared/extended in %d files (jumped to first)', word, #decls),
			vim.log.levels.INFO
		)
	end
end

local function find_type()
	local hybris_home = scanner.find_hybris_home()
	if not hybris_home then
		vim.notify("Hybris: HYBRIS_HOME is not set or points to an invalid directory.", vim.log.levels.ERROR)
		return
	end
	types.ensure(hybris_home, project_root(), function()
		local ok_telescope = pcall(require, "telescope")
		if not ok_telescope then
			vim.notify("Hybris: telescope.nvim not available", vim.log.levels.WARN)
			return
		end
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local conf = require("telescope.config").values
		local entry_display = require("telescope.pickers.entry_display")
		local finders = require("telescope.finders")
		local pickers = require("telescope.pickers")

		local items = types.all_types()
		local code_width = 0
		for _, item in ipairs(items) do
			code_width = math.max(code_width, vim.fn.strdisplaywidth(item.code))
		end
		code_width = code_width + 2

		local displayer = entry_display.create({
			separator = " ",
			items = {
				{ width = code_width },
				{ remaining = true },
			},
		})

		pickers
			.new({}, {
				prompt_title = "Hybris ItemTypes",
				finder = finders.new_table({
					results = items,
					entry_maker = function(item)
						return {
							value = item,
							ordinal = item.code,
							display = function(entry)
								return displayer({
									entry.value.code,
									entry.value.extends and ("extends " .. entry.value.extends) or "",
								})
							end,
						}
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						if selection and selection.value then
							jump_to_declaration(selection.value.file, selection.value.line)
						end
					end)
					return true
				end,
			})
			:find()
	end)
end

local function reindex_types()
	local hybris_home = scanner.find_hybris_home()
	if not hybris_home then
		vim.notify("Hybris: HYBRIS_HOME is not set or points to an invalid directory.", vim.log.levels.ERROR)
		return
	end
	types.ensure(hybris_home, project_root(), function(stats)
		vim.notify(
			string.format(
				"Hybris: type system rebuilt (%d files, %d types, %d enums).",
				stats.files,
				stats.types,
				stats.enums
			),
			vim.log.levels.INFO
		)
	end, true)
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
		LYRDJavaHybrisAttachDebugger = L.LYRDJavaHybrisAttachDebugger,
		LYRDJavaHybrisFindType = L.LYRDJavaHybrisFindType,
		LYRDJavaHybrisReindexTypes = L.LYRDJavaHybrisReindexTypes,
	})
	commands.implement("*", {
		{ L.LYRDJavaHybrisImportSolution, import_solution },
		{ L.LYRDJavaHybrisLoadSolution, reload_solution },
		{ L.LYRDJavaHybrisConfigureSolution, configure_solution },
		{ L.LYRDJavaHybrisCurrentConfig, show_current_config },
		{ L.LYRDJavaHybrisOpenConfigFile, open_config_file },
		{ L.LYRDJavaHybrisAttachDebugger, attach_debugger },
		{ L.LYRDJavaHybrisFindType, find_type },
		{ L.LYRDJavaHybrisReindexTypes, reindex_types },
	})
	-- Register custom overseer task providers
	local overseer = require("overseer")
	overseer.register_template(require("LYRD.shared.overseer.hybris_tasks"))

	-- Registers dap.adapters.java (via nvim-jdtls) and the Hybris/Spring
	-- remote-attach configs, so :DapContinue's picker (already wired to the
	-- generic Debug menu in layers/debug.lua + layers/lyrd-keyboard.lua) offers
	-- them with no session active.
	dap_hybris.setup()

	-- Registers the Type System completion source (items.xml/impex), scoped to
	-- those filetypes only. nvim-cmp is loaded on-demand here the same way
	-- dap/jdtls already are above -- require() triggers Lazy's load hook.
	local ok_cmp, cmp = pcall(require, "cmp")
	if ok_cmp then
		pcall(cmp.register_source, "hybris_types", require("LYRD.shared.hybris.cmp_source").new())
		local function hybris_sources()
			return cmp.config.sources({ { name = "hybris_types" } }, { { name = "buffer" }, { name = "path" } })
		end
		cmp.setup.filetype("impex", { sources = hybris_sources() })
		cmp.setup.filetype("xml", { sources = hybris_sources() })
	end
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
			{ "d", L.LYRDJavaHybrisAttachDebugger },
			{ "t", L.LYRDJavaHybrisFindType },
			{ "T", L.LYRDJavaHybrisReindexTypes },
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

	-- Warm-start jdtls in the background at startup when this project looks like
	-- a Hybris checkout, so the JVM boots and starts indexing while the user is
	-- still browsing/reading -- the first Java file opened then reuses this
	-- already-warming client (vim.lsp dedupes by {name, root_dir}) instead of a
	-- cold start. No-op when HYBRIS_HOME isn't set/valid for this project.
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("LYRDHybrisWarmStart", { clear = true }),
		once = true,
		callback = function()
			if not scanner.find_hybris_home() then
				return
			end

			-- Best-effort: run before anything (native autostart or our own
			-- warm-start below) actually reads vim.lsp.config.jdtls to spawn, so
			-- the very first boot already has the cached sourcePaths/exclusions.
			preload_cached_config()

			local function start_warm(jdtls_config)
				vim.lsp.start(jdtls_config, { attach = false })
			end

			local function has_java_buffer()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local ft = vim.bo[buf].filetype
					if ft == "java" or ft == "jproperties" then
						return true
					end
				end
				return false
			end

			local ok, jdtls_config = pcall(function()
				return vim.lsp.config.jdtls
			end)
			if not ok or not jdtls_config then
				return
			end

			if not has_java_buffer() then
				-- Nothing else can race us into starting jdtls (its FileType
				-- autostart only fires for a java/jproperties buffer) -- go now,
				-- no need to wait.
				start_warm(jdtls_config)
				return
			end

			-- A java/jproperties buffer already exists (e.g. passed on the
			-- command line), so jdtls's own FileType autostart is likely already
			-- in flight -- it can take over a second to actually attach on a
			-- cold start (Mason path resolution, etc.), so starting
			-- unconditionally here raced it in testing and spawned a second JVM.
			-- Poll a few times (5 x 500ms); if a client shows up at any point,
			-- skip -- there's nothing left to warm.
			local attempts = 0
			local function maybe_warm_start()
				attempts = attempts + 1
				if #vim.lsp.get_clients({ name = "jdtls" }) > 0 then
					return
				end
				if attempts < 5 then
					vim.defer_fn(maybe_warm_start, 500)
					return
				end
				start_warm(jdtls_config)
			end
			vim.defer_fn(maybe_warm_start, 500)
		end,
	})

	-- Warm the Type System index at startup too, same gate/pattern as the
	-- jdtls warm-start above but its own augroup: cheap (in-memory -> disk
	-- cache -> chunked async build), and unrelated to jdtls's own lifecycle.
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("LYRDHybrisTypesWarmStart", { clear = true }),
		once = true,
		callback = function()
			local hybris_home = scanner.find_hybris_home()
			if not hybris_home then
				return
			end
			types.ensure(hybris_home, project_root())
		end,
	})

	-- items.xml/impex buffers: make sure the index is available (usually a
	-- no-op, already warmed) and bind go-to-definition for the type/enum
	-- under the cursor.
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("LYRDHybrisTypesFileType", { clear = true }),
		pattern = { "xml", "impex" },
		callback = function(args)
			local is_items_xml = vim.api.nvim_buf_get_name(args.buf):match("items%.xml$") ~= nil
			if vim.bo[args.buf].filetype ~= "impex" and not is_items_xml then
				return
			end
			local hybris_home = scanner.find_hybris_home()
			if hybris_home then
				types.ensure(hybris_home, project_root())
			end
			-- LETTER NEEDS CONFIRMATION: propose <leader>jt ("jump to type"),
			-- adjust if it collides with something you already use.
			vim.keymap.set(
				"n",
				"<leader>jt",
				goto_type_definition,
				{ buffer = args.buf, desc = "Hybris: go to type/enum definition" }
			)
		end,
	})

	-- Keep completion fresh in-session: reindex after saving any *items.xml.
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("LYRDHybrisTypesReindexOnSave", { clear = true }),
		pattern = { "*items.xml" },
		callback = function()
			local hybris_home = scanner.find_hybris_home()
			if hybris_home then
				types.ensure(hybris_home, project_root(), nil, true)
			end
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
