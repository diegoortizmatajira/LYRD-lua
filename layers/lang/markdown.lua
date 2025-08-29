local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")

---@class LYRD.setup.Module
local L = { name = "Markdown" }

function L.plugins()
	setup.plugin({
		{
			"MeanderingProgrammer/markdown.nvim",
			main = "render-markdown",
			ft = { "markdown", "Avante", "codecompanion" },
			opts = {
				file_types = { "markdown", "Avante", "codecompanion" },
				heading = {
					sign = false,
					icons = {
						icons.styles.h1,
						icons.styles.h2,
						icons.styles.h3,
						icons.styles.h4,
						icons.styles.h5,
						icons.styles.h6,
					},
					width = "block",
				},
				code = {
					sign = false,
					width = "block", -- use 'language' if colorcolumn is important for you.
					right_pad = 1,
				},
				dash = {
					width = 79,
				},
				pipe_table = {
					style = "full", -- use 'normal' if colorcolumn is important for you.
				},
			},
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			}, -- if you prefer nvim-web-devicons
		},
	})
end

function L.preparation()
	-- Registers code actions in NULL LS
	local lsp = require("LYRD.layers.lsp")
	lsp.mason_ensure({
		"prettier",
		"marksman",
		"markdownlint-cli2",
		"markdown-toc",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"markdown",
		"mermaid",
	})
	lsp.customize_formatter("markdown-toc", {
		condition = function(_, ctx)
			for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
				if line:find("<!%-%- toc %-%->") then
					return true
				end
			end
		end,
		args = { "--bullets", "-", "-i", "$FILENAME" },
	})
	lsp.customize_formatter("markdownlint-cli2", {
		condition = function(_, ctx)
			local diag = vim.tbl_filter(function(d)
				return d.source == "markdownlint-cli2"
			end, vim.diagnostic.get(ctx.buf))
			return #diag > 0
		end,
	})
	--- Configures multiple formatters for markdown files, but first it will run a custom function to reflow the text.
	lsp.format_with_conform(
		{ "markdown", "markdown.mdx" },
		{ "prettier", "markdownlint-cli2", "markdown-toc" },
		function()
			-- Reflow the text first
			vim.cmd("normal! gggwG")
		end
	)
	lsp.null_ls_register_sources({
		require("null-ls.builtins.diagnostics.markdownlint_cli2"),
	})
end

function L.complete()
	vim.lsp.enable("marksman")
end

return L
