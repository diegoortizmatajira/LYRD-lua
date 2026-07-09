local lsp = require("LYRD.layers.lsp")
local join = require("LYRD.shared.utils").join_paths
local jdtls = require("jdtls")
local jdtls_install = lsp.get_pkg_path("jdtls")
local generator = require("LYRD.layers.lang.java-generator")

local bundles = {}

local root_files = {
	".git",
	"mvnw",
	"gradlew",
	"pom.xml",
	"build.gradle",
	"build.sbt",
}
local plug_jar_map = {
	["java-test"] = {
		dir = "server",
		patterns = {
			"junit-jupiter-api_*.jar",
			"junit-jupiter-engine_*.jar",
			"junit-jupiter-migrationsupport_*.jar",
			"junit-jupiter-params_*.jar",
			"junit-platform-commons_*.jar",
			"junit-platform-engine_*.jar",
			"junit-platform-launcher_*.jar",
			"junit-platform-runner_*.jar",
			"junit-platform-suite-api_*.jar",
			"junit-platform-suite-commons_*.jar",
			"junit-platform-suite-engine_*.jar",
			"junit-vintage-engine_*.jar",
			"org.apiguardian.api_*.jar",
			"org.eclipse.jdt.junit4.runtime_*.jar",
			"org.eclipse.jdt.junit5.runtime_*.jar",
			"org.opentest4j_*.jar",
			"com.microsoft.java.test.plugin-*.jar",
		},
	},
	["java-debug-adapter"] = { dir = "server", patterns = { "*.jar" } },
	-- Disabled: spring-boot-tools bundles fail OSGi loading (commons-lsp-extensions.jar,
	-- xml-ls-extension.jar have broken/incompatible manifests). jdtls crashes on init.
	-- java-debug-adapter is sufficient; can re-enable if spring-boot-tools versions improve.
	-- ["spring-boot-tools"] = { dir = "jars", patterns = { "*.jar" } },
}

local function get_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
	local project_path_hash = string.gsub(project_path, "[/\\:+-]", "_")

	local nvim_cache_path = vim.fn.stdpath("cache")
	return join(nvim_cache_path, "jdtls", "workspaces", project_path_hash)
end

-- Sizes the JVM heap to the machine: ~40% of RAM, clamped to [4,16]GB. Large
-- multi-module workspaces (e.g. a Hybris monorepo with hundreds of source
-- roots) can OOM well below 4G (eclipse.jdt.ls#1469); above 16G shows
-- diminishing returns. -Xms stays modest so the ceiling is only reached if
-- indexing actually needs it. Override per-machine via $NVIM_JDTLS_XMX_GB.
local function compute_heap_gb()
	local override = tonumber(vim.env.NVIM_JDTLS_XMX_GB)
	if override and override >= 1 then
		return override
	end
	local uv = vim.uv or vim.loop
	local total_gb = math.floor((uv.get_total_memory() or 8 * 1024 ^ 3) / (1024 ^ 3))
	return math.max(4, math.min(16, math.floor(total_gb * 0.40)))
end

-- Parallelizes the initial multi-project build (indexing itself is
-- single-threaded/IO-bound and can't be parallelized, eclipse.jdt.ls#3421, but
-- the build is). Leaves one core for the UI; capped since each concurrent
-- build costs RAM.
local function compute_max_concurrent_builds()
	local uv = vim.uv or vim.loop
	local cores = (uv.available_parallelism and uv.available_parallelism()) or 4
	return math.max(1, math.min(cores - 1, 8))
end

-- jdtls (and bundled extensions like java-debug-adapter/spring-boot-tools)
-- need a modern JVM to LAUNCH the server process itself -- separate from the
-- "runtimes" registered for the PROJECT's own source/target level. Trusting a
-- bare "java" from $PATH is inconsistent across platforms (macOS especially:
-- system stub vs Homebrew vs SDKMAN can all disagree) and can silently
-- resolve to something too old, which surfaces as OSGi bundle-activation
-- failures at a completely different layer (e.g. "Unresolved requirement:
-- osgi.ee ... version=21" cascading into org.eclipse.jdt.core failing to
-- fully initialize before another bundle depends on it -- a confusing,
-- hard-to-diagnose failure mode). Prefers JAVA_HOME, then the highest
-- sufficiently-modern runtime java-generator.lua already discovers, and
-- only falls back to a bare "java" if nothing better is found.
local MIN_LAUNCHER_JAVA_VERSION = 21

---@return string
local function resolve_launcher_java()
	local java_home = os.getenv("JAVA_HOME")
	if java_home and java_home ~= "" then
		local candidate = join(java_home, "bin", "java")
		if vim.fn.executable(candidate) == 1 then
			return candidate
		end
	end

	local best_path, best_version
	for _, runtime in ipairs(generator.get_runtimes()) do
		local version = tonumber(runtime.name:match("JavaSE%-(%d+)"))
		if version and version >= MIN_LAUNCHER_JAVA_VERSION and (not best_version or version > best_version) then
			best_version = version
			best_path = runtime.path
		end
	end
	if best_path then
		local candidate = join(best_path, "bin", "java")
		if vim.fn.executable(candidate) == 1 then
			return candidate
		end
	end

	return "java"
end

-- Kills an ORPHANED jdtls from a prior session that still holds this
-- workspace's `-data` lock (.metadata/.lock), before we start ours -- a live
-- orphan holding the lock would otherwise deadlock the new server. Orphans
-- only arise from a SIGKILL/terminal-close/crash (a normal :q stops jdtls
-- cleanly); matched by the exact `-data <workspace_path>` token so a sibling
-- workspace whose path is a prefix can never match, and restricted to
-- PPID==1 (a true orphan) so a healthy jdtls from another running nvim on the
-- same project is never touched. POSIX only; opt out with $NVIM_JDTLS_NO_REAP=1.
local function reap_stale_jdtls(workspace_path)
	if not workspace_path or workspace_path == "" then
		return
	end
	if vim.env.NVIM_JDTLS_NO_REAP == "1" or vim.fn.has("win32") == 1 then
		return
	end

	local uv = vim.uv or vim.loop
	local self_pid = tostring(vim.fn.getpid())
	local needle = "-data " .. workspace_path
	local victims = {}
	for _, line in ipairs(vim.fn.systemlist({ "ps", "-A", "-o", "pid=", "-o", "command=" })) do
		local pid, command = line:match("^%s*(%d+)%s+(.*)$")
		if pid and command and pid ~= self_pid and command:find("org.eclipse.jdt.ls", 1, true) then
			local _, needle_end = command:find(needle, 1, true)
			if needle_end then
				local after = command:sub(needle_end + 1, needle_end + 1)
				if after == "" or after:match("%s") then
					local ppid_out = vim.fn.systemlist({ "ps", "-o", "ppid=", "-p", pid })
					if tonumber((ppid_out[1] or ""):match("%d+")) == 1 then
						table.insert(victims, tonumber(pid))
					end
				end
			end
		end
	end
	if #victims == 0 then
		return
	end

	-- SIGTERM now (mirrors nvim's own stop), SIGKILL survivors after a grace window.
	for _, pid in ipairs(victims) do
		pcall(uv.kill, pid, 15)
	end
	vim.defer_fn(function()
		for _, pid in ipairs(victims) do
			local ok, alive = pcall(uv.kill, pid, 0)
			if ok and alive == 0 then
				pcall(uv.kill, pid, 9)
			end
		end
	end, 1500)
	vim.notify(
		string.format("jdtls: reaped %d orphaned process(es) holding %s", #victims, workspace_path),
		vim.log.levels.INFO
	)
end

-- Includes all JAR files from the mason packages that match the specified patterns.
for mason_package, config in pairs(plug_jar_map) do
	local pkg_install = lsp.get_pkg_path(mason_package)
	for _, jar_pattern in ipairs(config.patterns) do
		local pkg_bundle = vim.split(vim.fn.glob(join(pkg_install, "extension", config.dir, jar_pattern)), "\n")
		if pkg_bundle[1] ~= "" then
			vim.list_extend(bundles, pkg_bundle)
		end
	end
end

-- Configures the platform-specific settings for JDTLS.
local platform_config = join(jdtls_install, "config_linux")
if vim.fn.has("mac") == 1 then
	platform_config = join(jdtls_install, "config_mac")
elseif vim.fn.has("win32") == 1 then
	platform_config = join(jdtls_install, "config_win")
end
local lombok_install = lsp.get_pkg_path("lombok-nightly")
local paths = {
	data_dir = join(vim.fn.stdpath("cache"), "nvim-jdtls"),
	java_agent = join(lombok_install, "lombok.jar"),
	launcher_jar = vim.fn.glob(join(jdtls_install, "plugins", "org.eclipse.equinox.launcher_*.jar")),
	runtimes = generator.get_runtimes(),
	workspace_path = get_workspace_path(),
	jdtls_config = join(vim.fn.stdpath("cache"), "jdtls", "config"),
}

-- Reap any orphaned jdtls holding this workspace's lock before we start ours.
-- Runs once: this module's top level only executes once per session (Lua
-- caches `require`d modules, and vim.lsp.enable("jdtls") loads this file once).
reap_stale_jdtls(paths.workspace_path)

return {
	cmd = {
		resolve_launcher_java(),
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dosgi.checkConfiguration=true",
		"-Dosgi.sharedConfiguration.area=" .. platform_config,
		"-Dosgi.sharedConfiguration.area.readOnly=true",
		"-Dosgi.configuration.cascaded=true",
		"-Xms1G",
		"-Xmx" .. compute_heap_gb() .. "G",
		"-XX:+UseG1GC",
		"-XX:+UseStringDeduplication",
		"-Dlog.level=ERROR",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. paths.java_agent,
		"-jar",
		paths.launcher_jar,
		"-clean",
		"-configuration",
		paths.jdtls_config,
		"-data",
		paths.workspace_path,
	},
	filetypes = {
		"java",
		"jproperties",
		-- "xml",
		-- "yaml",
	},
	settings = {
		java = {
			-- Parallelizes the initial multi-project build across the machine's
			-- cores (indexing itself can't be parallelized, so this only helps
			-- the build phase).
			maxConcurrentBuilds = compute_max_concurrent_builds(),
			jdt = {
				ls = {
					lombokSupport = {
						enabled = true,
					},
				},
			},
			project = {
				referencedLibraries = {
					-- add any library jars here for the lsp to pick them up
				},
			},
			eclipse = {
				downloadSources = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = paths.runtimes,
			},
			maven = {
				downloadSources = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			inlayHints = {
				enabled = true,
				--parameterNames = {
				--   enabled = 'all' -- literals, all, none
				--}
			},
			format = {
				enabled = true,
				-- settings = {
				--   profile = 'asdf'
				-- },
			},
		},
		signatureHelp = {
			enabled = true,
		},
		completion = {
			favoriteStaticMembers = {
				"org.hamcrest.MatcherAssert.assertThat",
				"org.hamcrest.Matchers.*",
				"org.hamcrest.CoreMatchers.*",
				"org.junit.jupiter.api.Assertions.*",
				"java.util.Objects.requireNonNull",
				"java.util.Objects.requireNonNullElse",
				"org.mockito.Mockito.*",
			},
		},
		contentProvider = {
			preferred = "fernflower",
		},
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
		sources = {
			organizeImports = {
				starThreshold = 9999,
				staticStarThreshold = 9999,
			},
		},
		codeGeneration = {
			toString = {
				template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
			},
			useBlocks = true,
		},
	},
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root = jdtls.setup.find_root(root_files, fname)
		on_dir(root or vim.fn.getcwd())
	end,
	flags = {
		allow_incremental_sync = true,
	},
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
	},
}
