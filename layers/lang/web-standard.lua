local declarative_layer = require("LYRD.shared.declarative_layer")

-- Kept as a named table (rather than inline plugin opts) so `L.settings()`
-- below can re-`setup()` the plugin with a discovered `style_sheets` list
-- while reusing every other option unchanged. Re-`setup()`-ing with only a
-- partial opts table would reset `enable_on`/`handlers`/`peek`/etc. back to
-- the plugin's own defaults, since it merges the given opts against its
-- defaults, not against the previous call's opts.
local html_css_opts = {
	enable_on = {
		"html",
		"htmldjango",
		"tsx",
		"jsx",
		"erb",
		"svelte",
		"vue",
		"blade",
		"php",
		"templ",
		"astro",
	},
	handlers = {
		definition = {
			bind = "gd",
		},
		hover = {
			bind = "K",
			wrap = true,
			border = "none",
			position = "cursor",
		},
	},
	documentation = {
		auto_show = true,
	},
	peek = {
		enabled = true,
		border = "rounded",
		position = "center",
		width = 0.5,
		height = 0.5,
		focus = true,
		style = "minimal",
	},
	style_sheets = {
		"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
		"https://cdnjs.cloudflare.com/ajax/libs/bulma/1.0.3/css/bulma.min.css",
		"./index.css", -- `./` refers to the current working directory.
	},
}

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Web Standard Languages: HTML, CSS, SCSS",
	required_plugins = {
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"windwp/nvim-autopairs",
			},
			opts = {},
		},
		{
			"jezda1337/nvim-html-css",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			opts = html_css_opts,
		},
	},
	required_mason_packages = {
		"html-lsp",
		"css-lsp",
		"emmet-language-server",
		"emmet-ls",
		"prettier",
	},
	required_treesitter_parsers = {
		"html",
		"css",
		"scss",
	},
	required_enabled_lsp_servers = {
		"emmet_language_server",
		"cssls",
		"html",
	},
	required_null_ls_sources = {
		declarative_layer.source_with_opts("null-ls.builtins.formatting.prettier", {
			extra_filetypes = { "htmldjango" },
		}),
	},
	required_formatter_per_filetype = {
		{
			target_filetype = {
				"html",
				"htmldjango",
				"less",
				"css",
				"scss",
			},
			format_settings = { "prettier" },
		},
	},
}

--- Re-`setup()`s nvim-html-css with `html_css_opts.style_sheets` extended by
--- whatever `shared/css_discovery` found for the current buffer's project,
--- dropping any entry (static or discovered) that doesn't actually exist on
--- disk -- e.g. the curated `"./index.css"` placeholder, in a project that
--- doesn't have one -- instead of leaving it for nvim-html-css to warn about
--- and drop itself. No-ops (without re-`setup()`-ing) when this project's
--- stylesheets were already discovered and applied in this session.
local function apply_discovered_stylesheets()
	local css_discovery = require("LYRD.shared.css_discovery")
	local discovered, is_new = css_discovery.discover_for_current_buffer()
	if not discovered or not is_new then
		return
	end

	local opts = vim.deepcopy(html_css_opts)
	local merged = vim.list_extend(opts.style_sheets, discovered)
	opts.style_sheets = css_discovery.filter_existing(merged)
	require("html-css").setup(opts)

	vim.notify(
		string.format("[LYRD] html-css: %d stylesheet(s) registered (%d discovered)", #opts.style_sheets, #discovered),
		vim.log.levels.INFO
	)
end

--- Builds the full list of stylesheets currently registered for the current
--- buffer's project: the static/curated entries from `html_css_opts` plus
--- whatever `shared/css_discovery` has found (scanning now if it hasn't run
--- yet for this root). Each entry is `{ path, source }`, `path` as stored in
--- `style_sheets` (relative to Neovim's startup cwd, or a remote URL).
--- @return { path: string, source: "static"|"discovered" }[]
local function list_style_sheet_entries()
	local css_discovery = require("LYRD.shared.css_discovery")
	local entries = {}
	-- Discovered entries are already guaranteed to exist (found by walking
	-- real files); only the curated static list can contain stale entries.
	for _, path in ipairs(css_discovery.filter_existing(html_css_opts.style_sheets)) do
		table.insert(entries, { path = path, source = "static" })
	end
	local discovered = css_discovery.discover_for_current_buffer()
	for _, path in ipairs(discovered or {}) do
		table.insert(entries, { path = path, source = "discovered" })
	end
	return entries
end

--- Shows the stylesheets currently registered for the current buffer's
--- project (static + discovered) via `vim.ui.select`; picking a local entry
--- opens it, picking a remote one just reports its URL.
local function show_style_sheet_entries()
	local css_discovery = require("LYRD.shared.css_discovery")
	local entries = list_style_sheet_entries()
	if #entries == 0 then
		vim.notify("[LYRD] html-css: no stylesheets registered for this project", vim.log.levels.INFO)
		return
	end

	vim.ui.select(entries, {
		prompt = string.format("html-css stylesheets (%d)", #entries),
		format_item = function(entry)
			return string.format("[%s] %s", entry.source, entry.path)
		end,
	}, function(entry)
		if not entry then
			return
		end
		if entry.path:match("^https?://") then
			vim.notify(entry.path, vim.log.levels.INFO)
			return
		end
		local abs = css_discovery.to_absolute(entry.path)
		if vim.fn.filereadable(abs) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(abs))
		else
			vim.notify("[LYRD] html-css: file not found on disk: " .. abs, vim.log.levels.WARN)
		end
	end)
end

function L.settings()
	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd

	vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
		group = vim.api.nvim_create_augroup("LYRDCssDiscovery", { clear = true }),
		pattern = vim.tbl_map(function(ft)
			return "*." .. ft
		end, { "vue", "html", "js", "ts", "jsx", "tsx" }),
		callback = apply_discovered_stylesheets,
	})

	commands.implement("*", {
		{
			cmd.LYRDCssRefreshStylesheets,
			function()
				local css_discovery = require("LYRD.shared.css_discovery")
				local root = css_discovery.invalidate_current()
				if not root then
					vim.notify("[LYRD] html-css: no project root detected for current buffer", vim.log.levels.WARN)
					return
				end
				apply_discovered_stylesheets()
			end,
		},
		{ cmd.LYRDCssListStylesheets, show_style_sheet_entries },
	})
end

return declarative_layer.apply(L)
