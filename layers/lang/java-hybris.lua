local commands = require("LYRD.layers.commands")
local icons = require("LYRD.layers.icons")
local Command = commands.Command
local declarative_layer = require("LYRD.shared.declarative_layer")

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
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

---@return string?
local function find_hybris_home()
	local hybris_home = os.getenv("HYBRIS_HOME")
	if hybris_home and hybris_home ~= "" and vim.fn.isdirectory(hybris_home) == 1 then
		return hybris_home
	end
	return nil
end

---@param hybris_home string
---@return string[]
local function collect_platform_jars(hybris_home)
	local jars = {}
	-- Patterns use a single glob level (*) for reliability; add new entries for extra Hybris layouts
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
	return jars
end

---@param hybris_home string
---@return string[]
local function collect_eclipse_classpath_jars(hybris_home)
	local jars = {}
	local classpath_files =
		vim.split(vim.fn.glob(hybris_home .. "/bin/custom/**/.classpath"), "\n", { trimempty = true })
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
	return jars
end

---@param jars string[]
---@return string[]
local function deduplicate_jars(jars)
	local seen = {}
	local result = {}
	for _, jar in ipairs(jars) do
		local norm = vim.fn.fnamemodify(jar, ":p")
		if not seen[norm] then
			seen[norm] = true
			table.insert(result, norm)
		end
	end
	return result
end

-- Mirrors the workspace path formula in runtime/lsp/jdtls.lua so we can wipe
-- the cache and force JDTLS to re-index with the new classpath.
local function get_jdtls_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
	local project_hash = string.gsub(project_path, "[/\\:+-]", "_")
	return vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", "workspaces", project_hash)
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

	vim.notify("Hybris: scanning " .. hybris_home .. " …", vim.log.levels.INFO)

	local platform_jars = collect_platform_jars(hybris_home)
	local eclipse_jars = collect_eclipse_classpath_jars(hybris_home)

	vim.notify(
		string.format(
			"Hybris: found %d platform JARs and %d Eclipse classpath JARs.",
			#platform_jars,
			#eclipse_jars
		),
		vim.log.levels.INFO
	)

	local all_jars = {}
	vim.list_extend(all_jars, platform_jars)
	vim.list_extend(all_jars, eclipse_jars)
	local unique_jars = deduplicate_jars(all_jars)

	vim.lsp.config("jdtls", {
		settings = {
			java = {
				project = {
					referencedLibraries = unique_jars,
				},
			},
		},
	})

	-- Wipe the JDTLS workspace cache so the server re-indexes from scratch with
	-- the new classpath rather than reusing a stale workspace.
	local workspace_path = get_jdtls_workspace_path()
	if vim.fn.isdirectory(workspace_path) == 1 then
		vim.fn.delete(workspace_path, "rf")
		vim.notify("Hybris: cleared JDTLS workspace cache at " .. workspace_path, vim.log.levels.INFO)
	end

	local client_count = 0
	for _, client in pairs(vim.lsp.get_clients({ name = "jdtls" })) do
		vim.lsp.stop_client(client.id)
		client_count = client_count + 1
	end

	local msg = string.format("Hybris: %d JARs registered with JDTLS.", #unique_jars)
	if client_count > 0 then
		msg = msg .. " Server stopped — re-open any Java file to reconnect and re-index."
	else
		msg = msg .. " Open a Java file to start JDTLS with the Hybris classpath."
	end
	vim.notify(msg, vim.log.levels.INFO)
end

-- ─── Layer lifecycle ──────────────────────────────────────────────────────────

function L.settings()
	commands.register({
		LYRDJavaHybrisLoadSolution = L.LYRDJavaHybrisLoadSolution,
	})
	commands.implement("*", {
		{ L.LYRDJavaHybrisLoadSolution, load_hybris_solution },
	})
end

function L.keybindings()
	local mappings = require("LYRD.layers.mappings")
	mappings.keys({
		{ "n", "<Space>cH", L.LYRDJavaHybrisLoadSolution },
	})
end

function L.complete()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		group = vim.api.nvim_create_augroup("LYRDHybrisDetection", { clear = true }),
		once = true,
		callback = function()
			if find_hybris_home() then
				vim.notify(
					"Hybris project detected (HYBRIS_HOME is set). Run LYRDJavaHybrisLoadSolution to load Hybris solution.",
					vim.log.levels.INFO
				)
			end
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
