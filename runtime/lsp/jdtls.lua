local params = require("LYRD.layers.lang.java").get_lsp_params()
return {
	cmd = {
		"java",

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. params.paths.java_agent,
		"-jar",
		params.paths.launcher_jar,
		"-configuration",
		params.paths.platform_config,
		"-data",
		params.paths.workspace_path,
	},
	--    filetypes={}
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
				runtimes = params.paths.runtimes,
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
		extendedClientCapabilities = params.extendedClientCapabilities,
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
}
