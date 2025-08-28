# LYRD (Layered) config for Neovim

<!-- toc -->

- [Summary](#summary)
- [Abstractions and Extensibility](#abstractions-and-extensibility)
- [UI Features](#ui-features)
- [Keyboard-Driven Workflow](#keyboard-driven-workflow)
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
- [Centralized IDE Functionalities](#centralized-ide-functionalities)
- [AI Integration](#ai-integration)
- [Installation](#installation)

<!-- tocstop -->

## Summary

LYRD is a Neovim configuration focusing on improved developer workflows and
custom UI enhancements. It provides features such as advanced notifications,
syntax highlighting, terminal integration, and session management. It also
supports easy navigation, file search, and command customization.

## Abstractions and Extensibility

LYRD is designed with abstractions in layers, commands, and keybindings to
enhance maintainability and extensibility:

- **Layered Architecture**:
  - Each layer encapsulates specific functionality, such as language support,
    UI enhancements, or tools.
  - Layers have lifecycle methods (`preparation`, `settings`, `keybindings`,
    `complete`) for modular configuration.
- **Command Abstractions**:
  - Custom commands are implemented to standardize functionality across layers.
  - For example, commands like `LYRDCodeRun`, `LYRDCodeBuild`, and `LYRDTest`
    offer consistent workflows.
- **Keybinding Management**:
  - Keybindings are defined per layer, ensuring that they remain
    context-specific and modular.
  - Layers can register file-type-specific actions to run only once per file
    type, ensuring efficiency.
- **Plugin Management**:
  - Plugins are defined and scoped per layer, allowing for lazy loading and
    reducing startup time.

This design ensures that the configuration is easy to extend and maintain, and
minimizes conflicts between layers and plugins.

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
- **Autocompletion**:
  - LSP completions (functions, variables, types, etc.)
  - Code snippet support
  - AI code completion

## Keyboard-Driven Workflow

LYRD emphasizes a keyboard-driven workflow, offering developers an efficient
and intuitive way to interact with Neovim. Key features include:

- **Feature-Based Grouping**:
  - Keybindings are logically grouped by features, ensuring consistency and
    reducing cognitive load for developers.
- **Ease of Memorization**:
  - Mnemonic and descriptive keybinding patterns make them easy to remember,
    even for complex workflows.
- **Enhanced by Plugins**:
  - Plugins like `which-key.nvim` provide on-the-fly keybinding descriptions
    and organize them visually, making it easier to discover and use them.
- **Descriptive Icons**:
  - Integration with plugins ensures that keybindings are accompanied by
    meaningful icons, improving usability and aesthetics.

This approach ensures that developers can focus on their tasks without needing
to frequently consult documentation, enhancing productivity and maintaining
flow.

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
  - Jupyter Notebooks: Includes support for Jupyter notebooks in Neovim buffers
    with execution capabilities, powered by plugins such as `iron.nvim`,
    `NotebookNavigator.nvim`, and `jupytext.nvim`.

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

## Centralized IDE Functionalities

LYRD centralizes essential IDE functionalities to ensure streamlined and cohesive workflows. The following modules play a key role in providing a rich development experience:

- **Test Management** (`test.lua`): Simplifies running and managing tests
  across supported languages.
- **Debugging** (`debug.lua`): Offers integrated debugging capabilities with
  support for language-specific adapters.
- **Code Completion** (`completion.lua`): Enhances code completion using
  language servers and custom logic.
- **Development Tools** (`dev.lua`): Houses tools for rapid development, such
  as code generation and refactoring utilities.
- **File Templates** (`file_templates.lua`): Facilitates the creation of
  boilerplate code or standardized file structures.
- **Git Integration** (`git.lua`): Provides Git-related features like diff
  viewing, staging, and committing changes.
- **REST Client** (`rest.lua`): Enables testing and interacting with REST APIs
  directly from Neovim.
- **Syntax Highlighting** (`treesitter.lua`): Leverages Treesitter for advanced
  syntax highlighting and parsing.
- **Task Management** (`tasks.lua`): Includes robust task management
  capabilities through `overseer.nvim`. It supports a variety of task types
  out-of-the-box, including VSCode tasks, Make, Mage (go), Maven, and Cake
  Frosting (dotnet), enabling developers to seamlessly configure and monitor
  their workflows.
- **External Tool Integrations**:
  - **Docker** (`docker.lua`): Provides seamless integration with Docker
    through language servers for Dockerfile and Docker Compose. It includes
    support for linting with `hadolint` and a terminal-based UI powered by
    `lazydocker`.
  - **Kubernetes** (`kubernetes.lua`): Enables interaction with Kubernetes
    clusters using `k9s` for cluster management and Helm support for
    configuration.
  - **File Tree** (`filetree.lua`): Features the `nvim-tree` plugin for
    enhanced file browsing, with additional support for terminal-based file
    managers like `yazi`.
  - **Tmux** (`tmux.lua`): Integrates with Tmux for seamless pane navigation
    and manipulation using `vim-tmux-navigator` and `smart-splits.nvim`.
  - **Fuzzy Finder** (`telescope.lua`): Offers advanced file and content search
    capabilities enhanced by `telescope-fzf-native`. It supports a wide range of
    integrations, including LSP features, code outlines, and snippet selection.

This centralized approach ensures that developers can access all essential
tools and features without needing to switch contexts or install additional
plugins unnecessarily.

## AI Integration

LYRD integrates AI-powered tools to enhance the development workflow. These
integrations allow developers to:

- **Ask Questions**:
  - Use commands to query AI assistants for code-related help directly within
    Neovim.
- **Edit Files**:
  - Apply AI suggestions to refactor or edit existing code blocks efficiently.
- **Use Agents**:
  - Leverage agents to implement or refactor functionality, reducing manual
    effort.
- **Generate Documentation**:
  - Automatically create detailed documentation for code blocks using keyboard
    shortcuts, saving time and ensuring consistency.

These features are powered by plugins such as `Avante.nvim` and others,
offering flexibility and customization for different AI providers like Copilot,
Codeium, and Tabnine. Developers can benefit from:

- Auto-suggestions for code completion, with options to accept, dismiss, or
  navigate suggestions using configurable keybindings.
- Enhanced commands like:
  - `:LYRDSmartCoder` for AI-assisted editing.
  - `:LYRDAIGenerateDocumentation` to automatically generate documentation for
    the current element.
  - `:LYRDAIAssistant` to toggle AI functionality.
  - `:LYRDAIAsk` to ask AI questions interactively.
  - `:LYRDAIEdit` to invoke AI-powered editing directly.

This integration ensures streamlined workflows and boosts productivity by
leveraging the capabilities of advanced AI systems.

## Installation

Clone the repository into your Neovim config folder

```bash
git clone https://github.com/diegoortizmatajira/LYRD-lua.git ~/.config/nvim/lua/LYRD
```

Create a symbolic link to the lua init script.

```bash
ln -s ~/.config/nvim/lua/LYRD/root-init.lua ~/.config/nvim/init.lua
```
