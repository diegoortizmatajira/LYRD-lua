local lsp = require("LYRD.layers.lsp")
local join = require("LYRD.utils").join_paths
local jdtls = require("jdtls")
local jdtls_install = lsp.get_pkg_path("jdtls")

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
	["java-debug-adapter"] = { "*.jar" },
	["spring-boot-tools"] = { "jars/*.jar" },
}

local default_runtimes = {
	-- Note: the field `name` must be a valid `ExecutionEnvironment`,
	-- you can find the list here:
	-- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	{
		name = "JavaSE-1.8",
		path = "/usr/lib/jvm/java-8-openjdk",
	},
	{
		name = "JavaSE-11",
		path = "/usr/lib/jvm/java-11-openjdk",
	},
	{
		name = "JavaSE-17",
		path = "/usr/lib/jvm/java-17-openjdk",
		default = true,
	},
	{
		name = "JavaSE-21",
		path = "/usr/lib/jvm/java-21-openjdk",
	},
	{
		name = "JavaSE-24",
		path = "/usr/lib/jvm/java-24-openjdk",
	},
}

local function get_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
	local project_path_hash = string.gsub(project_path, "[/\\:+-]", "_")

	local nvim_cache_path = vim.fn.stdpath("cache")
	return join(nvim_cache_path, "jdtls", "workspaces", project_path_hash)
end

-- Includes all JAR files from the mason packages that match the specified patterns.
for mason_package, jars in pairs(plug_jar_map) do
	local pkg_install = lsp.get_pkg_path(mason_package)
	for _, jar_pattern in ipairs(jars) do
		local pkg_bundle = vim.split(vim.fn.glob(join(pkg_install, "extension", "server", jar_pattern)), "\n")
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
	runtimes = default_runtimes,
	workspace_path = get_workspace_path(),
	jdtls_config = join(vim.fn.stdpath("cache"), "jdtls", "config"),
}
return {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dosgi.checkConfiguration=true",
		"-Dosgi.sharedConfiguration.area=" .. platform_config,
		"-Dosgi.sharedConfiguration.area.readOnly=true",
		"-Dosgi.configuration.cascaded=true",
		"-Xms1G",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. paths.java_agent,
		"-jar",
		paths.launcher_jar,
		"-configuration",
		paths.jdtls_config,
		"-data",
		paths.workspace_path,
	},
	-- filetypes={}
	settings = {
		java = {
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
	root_dir = jdtls.setup.find_root(root_files),
	flags = {
		allow_incremental_sync = true,
	},
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
	},
}
