local commands = require("LYRD.layers.commands")
local cmd = require("LYRD.layers.lyrd-commands").cmd
local lsp = require("LYRD.layers.lsp")

---@class LYRD.setup.Module
local L = { name = "Docker" }

function L.toggle_lazydocker()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.toggle_external_app_terminal("lazydocker")
end

function L.preparation()
	lsp.mason_ensure({
		"dockerfile-language-server",
		"docker-compose-language-service",
		"hadolint",
	})
	lsp.null_ls_register_sources({
		require("null-ls.builtins.diagnostics.hadolint"),
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"dockerfile",
	})
end

function L.settings()
	vim.filetype.add({
		pattern = {
			["docker%-compose*%.yaml"] = "yaml.docker-compose",
			["docker%-compose*%.yml"] = "yaml.docker-compose",
		},
	})
	commands.implement("*", {
		{ cmd.LYRDContainersUI, L.toggle_lazydocker },
	})
end

function L.complete()
	vim.lsp.enable({
		"dockerls",
		"docker_compose_language_service",
	})
end

function L.healthcheck()
	vim.health.start(L.name)
	local health = require("LYRD.health")
	health.check_executable("lazydocker")
end

return L
