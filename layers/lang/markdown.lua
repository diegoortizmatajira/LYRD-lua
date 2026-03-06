local setup = require("LYRD.setup")
local icons = require("LYRD.layers.icons")

---@class LYRD.layer.lang.Markdown: LYRD.setup.Module
local L = {
	name = "Markdown",
	--- Defines custom formatters, order matters as they are applied in the order they are defined here.
	custom_formatters = {
		--- Configures a custom formatter for Markdown files that uses prettier
		--- with specific arguments to ensure that prose is wrapped and the print
		--- width is set to a specified value, enhancing readability and formatting
		--- consistency for Markdown content.
		["prettier_markdown"] = {
			inherit = "prettier",
			prepend_args = { "--prose-wrap", "always", "--print-width", tostring(80) },
		},

		--- Configures the markdown-toc formatter to only run when the buffer contains
		--- the string "<!-- toc -->", and if it does, it will generate a table of
		--- contents with bullet points using the "-" character.
		["markdown-toc"] = {
			condition = function(_, ctx)
				for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
					if line:find("<!%-%- toc %-%->") then
						return true
					end
				end
			end,
			args = { "--bullets", "-", "-i", "$FILENAME" },
		},

		--- Configures the markdownlint-cli2 formatter to only run when there are
		--- diagnostics in the buffer that have "markdownlint-cli2" as their source, ensuring
		--- that the formatter only runs when there are relevant issues to address.
		["markdownlint-cli2"] = {
			condition = function(_, ctx)
				local diag = vim.tbl_filter(function(d)
					return d.source == "markdownlint-cli2"
				end, vim.diagnostic.get(ctx.buf))
				return #diag > 0
			end,
		},
	},
}

function L.plugins()
	setup.plugin({
		{
			"MeanderingProgrammer/render-markdown.nvim",
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
			},
		},
		{
			"Nedra1998/nvim-mdlink",
			opts = {
				max_depth = 5,
				keymap = true,
				cmp = true,
			},
			dependencies = {
				"hrsh7th/nvim-cmp",
			},
		},
	})
end

function L.preparation()
	local lsp = require("LYRD.layers.lsp")
	lsp.mason_ensure({
		"prettier",
		"marksman",
		"markdownlint-cli2",
		"markdown-toc",
	})
	local ts = require("LYRD.layers.treesitter")
	ts.ensureParser({
		"latex",
		"markdown",
		"markdown_inline",
		"mermaid",
		"html",
		"yaml",
	})
	--- Iterates over the custom formatters defined in the `custom_formatters` table and
	--- registers each formatter with the LSP layer, allowing them to be used for formatting
	--- Markdown files according to the specified conditions and arguments defined for each formatter.
	for key, value in pairs(L.custom_formatters) do
		lsp.customize_formatter(key, value)
	end
	--- Configures the list of formatters to be applied to Markdown files,
	--- ensuring that the custom formatters defined in the `custom_formatters`
	--- table are used when formatting Markdown content.
	lsp.format_with_conform({ "markdown", "markdown.mdx" }, vim.tbl_keys(L.custom_formatters))
	--- Registers the markdownlint_cli2 diagnostic source with null-ls, enabling
	--- linting for Markdown files using the markdownlint-cli2 tool, which helps
	--- identify and fix issues in Markdown content according to the rules defined by markdownlint.
	lsp.null_ls_register_sources({
		require("null-ls.builtins.diagnostics.markdownlint_cli2"),
	})
end

function L.settings()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.register_decoration_togglers("markdown", { ":RenderMarkdown toggle" })
end

function L.complete()
	vim.lsp.enable("marksman")
end

return L
