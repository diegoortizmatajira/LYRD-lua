# LYRD (Layered) config for Neovim

<!-- toc -->

- [Summary](#summary)
- [UI Features](#ui-features)
- [Supported Programming Languages](#supported-programming-languages)
    * [CMake](#cmake)
    * [C and C++](#c-and-c)
    * [CSV](#csv)
    * [Data Formats](#data-formats)
    * [Go](#go)
    * [Java](#java)
    * [Kotlin](#kotlin)
    * [Lua](#lua)
    * [Markdown](#markdown)
    * [.NET (C#, F#, VB)](#net-c%23-f%23-vb)
    * [Python](#python)
    * [Rust](#rust)
    * [Web Frontend](#web-frontend)
    * [Web Standards](#web-standards)
- [Installation](#installation)

<!-- tocstop -->

## Summary

LYRD is a Neovim configuration focusing on improved developer workflows and
custom UI enhancements. It provides features such as advanced notifications,
syntax highlighting, terminal integration, and session management. It also
supports easy navigation, file search, and command customization.

## UI Features

- **Advanced Notifications**:
  - Integrated with `nvim-notify` for compact and visually appealing notifications.
- **Command Palette**:
  - Enhanced with `folke/noice.nvim` for streamlined command-line and popup
    menu visuals.
- **Status Line and Tabline**:
  - Managed by `nvim-lualine/lualine.nvim` with customizable sections and
    buffer/tabs display.
- **Startup Screen**:
  - Provided by `mini.starter` with recent files, workspaces, and common actions.
- **Floating Terminals**:
  - Powered by `toggleterm.nvim` for custom commands in a floating pane.
- **Scratch Buffers**:
  - Managed with `scratch.nvim` for temporary and easily accessible notes or code.
- **File Search and Replace**:
  - Enhanced by `nvim-spectre` for project-wide search and replace.
- **Focus Mode**:
  - Enabled by `twilight.nvim` for distraction-free coding sessions.
- **Cursor Position Memory**:
  - Automatically remembers and restores the last cursor position in files.
- **Yank Highlighting**:
  - Visual feedback when text is yanked, improving usability.

## Supported Programming Languages

### CMake

- **Key Features**:
  - Supported Language Server: `cmake-language-server`.
  - Treesitter parsers for `make` and `cmake`.
  - Automatic filetype detection for `CMakeLists.txt`.

### C and C++

- **Key Features**:
  - Language Servers: `clangd`, `codelldb`.
  - Formatters: `clang-format`.
  - Testing Frameworks: `neotest-ctest`.
  - Debugging support for C and C++ projects.

### CSV

- **Key Features**:
  - Treesitter parsers for `csv` and `tsv`.
  - Plugin: `csvview.nvim` for enhanced CSV viewing.

### Data Formats

- **Key Features**:
  - Supported formats: JSON, YAML, TOML, XML.
  - LSP Servers for JSON (`json-lsp`), YAML, and XML.
  - Formatters: `prettier`, `xmlformatter`.
  - Validation tools: `yamllint`, `jsonlint`.

### Go

- **Key Features**:
  - Language Server: `gopls`.
  - Treesitter parsers: `go`, `gomod`, `gosum`, `gotmpl`.
  - Debugging support using `nvim-dap-go`.
  - Code generation and refactoring tools: `gomodifytags`, `impl`.
  - Testing Framework: `neotest-golang`.

### Java

- **Key Features**:
  - Language Server: `jdtls`.
  - Testing Frameworks: `neotest-java`.
  - Debugging support through `java-debug-adapter`.
  - Managed runtimes and project-specific configurations.

### Kotlin

- **Key Features**:
  - Language Server: `kotlin-language-server`.
  - Formatter: `ktlint`.
  - Debugging support with `kotlin-debug-adapter`.

### Lua

- **Key Features**:
  - Language Server: `sumneko_lua`.
  - Treesitter support for Lua grammar and syntax.
  - Rich debugging support with external tools.

### Markdown

- **Key Features**:
  - Language Servers: `marksman`, `markdownlint-cli2`.
  - Treesitter parsers: `markdown`, `mermaid`.
  - Enhanced rendering with `MeanderingProgrammer/markdown.nvim`.
  - Formatting tools: `prettier`, `markdown-toc`.

### .NET (C#, F#, VB)

- **Key Features**:
  - Language Servers: `roslyn`, `netcoredbg`.
  - Debugging through `netcoredbg`.
  - Test adapters: `neotest-vstest`.

### Python

- **Key Features**:
  - Language Servers: `pyright`, `ruff`.
  - Treesitter support for Python and Django HTML.
  - Virtual environment management with `venv-selector.nvim`.
  - Debugging support through `nvim-dap-python`.
  - Testing Framework: `neotest-python`.

### Rust

- **Key Features**:
  - Language Servers: `rust-analyzer`, `bacon_ls`.
  - Testing Frameworks: `rustaceanvim.neotest`.
  - Debugging support through `codelldb`.
  - Crate management with `crates.nvim`.

### Web Frontend

- **Languages and Frameworks**: JavaScript, TypeScript, Vue, Angular.
- **Key Features**:
  - Language Servers for JavaScript (vtsls), Vue (vue_ls), Angular (angularls).
  - Treesitter support for JavaScript, TypeScript, Vue, TSX, and Angular.
  - Specialized testing adapters for Vitest and Jest.
  - Enhanced syntax highlighting for Angular HTML files.

### Web Standards

- **Languages and Frameworks**: HTML, CSS, SCSS, Emmet.
- **Key Features**:
  - Language Servers for HTML, CSS, and Emmet.
  - Prettier integration for formatting.
  - Treesitter support for HTML, CSS, and SCSS.
  - Autotag plugin for easier HTML tag management.

## Installation

Clone the repository into your Neovim config folder

```bash
git clone https://github.com/diegoortizmatajira/LYRD-lua.git ~/.config/nvim/lua/LYRD
```

Create a symbolic link to the lua init script.

```bash
ln -s ~/.config/nvim/lua/LYRD/root-init.lua ~/.config/nvim/init.lua
```
