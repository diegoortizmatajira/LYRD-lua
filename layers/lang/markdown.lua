local icons = require("LYRD.layers.icons")

local declarative_layer = require("LYRD.shared.declarative_layer")

--- @type table|LYRD.shared.setup.DeclarativeLayer
local L = {
	name = "Markdown Documents",
	required_plugins = {
		{
			"MeanderingProgrammer/render-markdown.nvim",
			main = "render-markdown",
			ft = { "markdown", "Avante", "codecompanion" },
			opts = {
				file_types = { "markdown", "Avante", "codecompanion" },
				completions = {
					lsp = {
						enabled = true,
					},
				},
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
				code = { sign = false, width = "block", right_pad = 1 },
				dash = { width = 79 },
				pipe_table = { style = "full" },
			},
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
		},
	},
	required_mason_packages = {
		"prettier",
		"marksman",
		"markdownlint-cli2",
		"markdown-toc",
	},
	required_treesitter_parsers = {
		"latex",
		"markdown",
		"markdown_inline",
		"mermaid",
		"html",
		"yaml",
	},
	required_enabled_lsp_servers = {
		"marksman",
	},
	required_formatters = {
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
	required_formatter_per_filetype = {
		{
			target_filetype = { "markdown", "markdown.mdx" },
			format_settings = { "prettier_markdown", "markdown-toc", "markdownlint-cli2" },
		},
	},
	required_null_ls_sources = {
		"null-ls.builtins.diagnostics.markdownlint_cli2",
	},
	required_executables = {
		"mdwatch",
	},
}

function L.preview_markdown()
	local command = "mdwatch"
	if vim.fn.executable(command) == 0 then
		vim.notify("mdwatch is not installed. Please install it using 'cargo install mdwatch'", vim.log.levels.ERROR)
		return
	end
	local tasks = require("LYRD.layers.tasks")
	local file = vim.api.nvim_buf_get_name(0)
	tasks.run_task({
		name = "Markdown Preview",
		cmd = command,
		args = {
			file,
		},
		open_in_split = true,
		focus = false,
	})
end

--- Finds the fenced code block or inline code span at the cursor and returns
--- its text with the fence/backtick delimiters stripped.
local function get_code_at_cursor()
	local node = vim.treesitter.get_node()
	while node do
		local node_type = node:type()
		if node_type == "fenced_code_block" then
			for child in node:iter_children() do
				if child:type() == "code_fence_content" then
					return vim.treesitter.get_node_text(child, 0)
				end
			end
			return vim.treesitter.get_node_text(node, 0)
		elseif node_type == "code_span" then
			return (vim.treesitter.get_node_text(node, 0):gsub("^`+", ""):gsub("`+$", ""))
		end
		node = node:parent()
	end
	return nil
end

function L.copy_code_block()
	local text = get_code_at_cursor()
	if not text then
		vim.notify("No code block or inline code found at cursor", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", text)
	vim.notify("Copied code to the clipboard!")
end

function L.settings()
	local ui = require("LYRD.layers.lyrd-ui")
	ui.register_decoration_togglers("markdown", { ":RenderMarkdown toggle" })

	local commands = require("LYRD.layers.commands")
	local cmd = require("LYRD.layers.lyrd-commands").cmd
	local markdown_table = require("LYRD.shared.utils.markdown_table")
	local markdown_format = require("LYRD.shared.utils.markdown_format")

	commands.implement("markdown", {
		{ cmd.LYRDDevServerStart, L.preview_markdown },
		{ cmd.LYRDCopyCodeBlock, L.copy_code_block },
		{ cmd.LYRDMarkdownToggleBold, markdown_format.toggle_bold },
		{ cmd.LYRDMarkdownToggleItalic, markdown_format.toggle_italic },
		{ cmd.LYRDMarkdownToggleUnderline, markdown_format.toggle_underline },
		{ cmd.LYRDMarkdownToggleStrikethrough, markdown_format.toggle_strikethrough },
		{ cmd.LYRDMarkdownToggleHighlight, markdown_format.toggle_highlight },
		{ cmd.LYRDMarkdownToggleSuperscript, markdown_format.toggle_superscript },
		{ cmd.LYRDMarkdownToggleSubscript, markdown_format.toggle_subscript },
		{ cmd.LYRDMarkdownToggleInlineCode, markdown_format.toggle_inline_code },
		{ cmd.LYRDMarkdownToggleCodeBlock, markdown_format.toggle_code_block },
		{ cmd.LYRDMarkdownToggleQuoteBlock, markdown_format.toggle_quote_block },
		{
			cmd.LYRDMarkdownTableMoveColumnLeft,
			function()
				markdown_table.move_column(-1)
			end,
		},
		{
			cmd.LYRDMarkdownTableMoveColumnRight,
			function()
				markdown_table.move_column(1)
			end,
		},
		{
			cmd.LYRDMarkdownTableInsertColumnLeft,
			function()
				markdown_table.insert_column(-1)
			end,
		},
		{
			cmd.LYRDMarkdownTableInsertColumnRight,
			function()
				markdown_table.insert_column(1)
			end,
		},
		{
			cmd.LYRDMarkdownTableInsertRowAbove,
			function()
				markdown_table.insert_row(-1)
			end,
		},
		{
			cmd.LYRDMarkdownTableInsertRowBelow,
			function()
				markdown_table.insert_row(1)
			end,
		},
	})
end

return declarative_layer.apply(L)
