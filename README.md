# LYRD (Layered) - A Complete Development Environment for Neovim

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Neovim 0.11+](https://img.shields.io/badge/Neovim-0.11%2B-57A143?logo=neovim&logoColor=white)](docs/installation.md#prerequisites)
[![Made with Lua](https://img.shields.io/badge/Made%20with-Lua-2C2D72?logo=lua&logoColor=white)](https://www.lua.org/)

LYRD (Layered Neovim) turns Neovim into a modern, IDE-like development
environment with a modular architecture, strong language tooling, integrated
testing/debugging, and keyboard-first workflows.

|                                                    |                                               |
| -------------------------------------------------- | --------------------------------------------- |
| ![Git UI](docs/images/git-status-panel.png)        | ![Debugging UI](docs/images/debug-panels.png) |
| ![Task Automation](docs/images/overseer-panel.png) | ![AI Chat Panel](docs/images/ai-panel.png)    |

More panels and workflows are in [docs/panels.md](docs/panels.md).

## Documentation

Start here, then jump to the topic you need:

| Topic                            | Document                                               |
| -------------------------------- | ------------------------------------------------------ |
| Overview and architecture        | [docs/overview.md](docs/overview.md)                   |
| Core feature catalog             | [docs/features.md](docs/features.md)                   |
| TUI panels and sidebars          | [docs/panels.md](docs/panels.md)                       |
| Keyboard-driven workflow         | [docs/keyboard-workflow.md](docs/keyboard-workflow.md) |
| Language support                 | [docs/language-support.md](docs/language-support.md)   |
| Installation                     | [docs/installation.md](docs/installation.md)           |
| Configuration and customization  | [docs/configuration.md](docs/configuration.md)         |
| Troubleshooting and help         | [docs/troubleshooting.md](docs/troubleshooting.md)     |
| Command and keybinding reference | [docs/commands.md](docs/commands.md)                   |

## Quick Start

1. Install prerequisites from
   [docs/installation.md#prerequisites](docs/installation.md#prerequisites).
2. Follow [Basic Installation](docs/installation.md#basic-installation).
3. Launch Neovim and let plugins install.
4. Run `:checkhealth LYRD` and review
   [Post-Installation](docs/installation.md#post-installation).

## Why LYRD

- **Ready out of the box** for beginners.
- **Modular and customizable** for experienced users.
- **Consistent commands** across languages.
- **Terminal-native** workflow that works locally and over SSH.
- **Nothing to take or leave** - built from independent layers, so you can adopt
  all of it or lift a single layer into your own config (see
  [Explore and Reuse the Source](#explore-and-reuse-the-source)).

## Quick IDE Comparison (for new users)

| Area                        | LYRD                                                       | VS Code                            | JetBrains IDEs                      | Visual Studio                   |
| --------------------------- | ---------------------------------------------------------- | ---------------------------------- | ----------------------------------- | ------------------------------- |
| Core model                  | Neovim-first, layer-based, keyboard-driven                 | Extension-based editor             | Full IDE suites per stack           | Full IDE focused on .NET/C++    |
| Out-of-box dev workflow     | Strong defaults with integrated testing, debug, tasks, Git | Good base, usually extension-heavy | Very strong, integrated by product  | Very strong for Microsoft stack |
| Customization depth         | Very high (Lua + layers)                                   | Very high (settings + extensions)  | Moderate to high (plugins/settings) | Moderate (extensions/settings)  |
| Terminal/SSH-first workflow | Native strength                                            | Good                               | Available, less terminal-native     | Available, less terminal-native |
| Performance profile         | Lightweight, fast startup and navigation                   | Lightweight to medium              | Medium to heavy (feature-rich)      | Medium to heavy (feature-rich)  |

### Features at a glance

LYRD includes integrated LSP tooling, formatting, testing, debugging, Git and
GitHub workflows (PRs, issues, a `gh dash` dashboard), tmux-backed long-running
task automation with recovery, AI-assisted coding, a REST client with
OpenAPI-to-`.http` generation, database tooling, container/Kubernetes support,
static-site (Hugo) workflows, and keyboard-first discovery workflows.

### Supported language ecosystems (high level)

Python, JavaScript/TypeScript, Java (including Hybris/SAP Commerce project
support), .NET (C#/F#/VB.NET), Go, Rust, C/C++, Dart/Flutter, Kotlin, Bash,
Ruby, PHP, Nix, Groovy, Pascal, LaTeX, SQL, plus common formats like
JSON/YAML/TOML/XML, Markdown, CMake, Protocol Buffers, and CSV/TSV.

For full details, see [docs/language-support.md](docs/language-support.md).

## Explore and Reuse the Source

LYRD isn't a monolith - it's organized as ~60 independently loadable **layers**,
each a self-contained Lua module for one capability (a language, Git, debugging,
a UI panel). You don't need to adopt the whole distribution to get value out of
it:

- Read [docs/overview.md](docs/overview.md) for the layer lifecycle and
  bootstrap chain, and [CLAUDE.md](CLAUDE.md) for the layer template used
  throughout the codebase.
- Most layers only depend on `shared/setup.lua` and a few small helpers in
  `utils/`, so a single layer file is usually easy to lift into another config.
- A few layers worth a look if you're building your own setup:
  - `layers/git.lua` - patch export/import, worktrees, and GitHub PR/issue
    workflows.
  - `layers/tasks.lua` - Overseer task templates with a tmux-backed
    long-running-task strategy and session recovery.
  - `layers/docker.lua` - Compose image picker/completion, backup/restore, and
    force-recreate helpers.
  - `layers/lang/java-hybris.lua` - SAP Commerce (Hybris) project detection and
    JDTLS/classpath wiring, one of the more involved language integrations.

Everything is plain Lua with LuaDoc annotations - no build step and no compiled
config DSL to reverse-engineer.

## Companion Plugins

A few standalone Neovim plugins maintained by the same author
([diegoortizmatajira](https://github.com/diegoortizmatajira)) power specific
LYRD layers and can be used on their own, independent of the rest of the
distribution:

| Plugin                                                                                             | Used in               | What it does                                                                                  |
| -------------------------------------------------------------------------------------------------- | --------------------- | --------------------------------------------------------------------------------------------- |
| [db-cli-adapter.nvim](https://github.com/diegoortizmatajira/db-cli-adapter.nvim)                   | `layers/lang/sql.lua` | Neovim adapter for DB CLI tools: output panel, backup/restore, connection-aware dialects.     |
| [workspace-scratch-files.nvim](https://github.com/diegoortizmatajira/workspace-scratch-files.nvim) | `layers/lyrd-ui.lua`  | Global and per-workspace scratch file management, including migrating between scopes.         |
| [breakpoints.nvim](https://github.com/diegoortizmatajira/breakpoints.nvim)                         | `layers/debug.lua`    | DAP breakpoint management with persistence and a picker (fork of lenincamp/breakpoints.nvim). |
| [jupytext.nvim](https://github.com/diegoortizmatajira/jupytext.nvim)                               | `layers/repl.lua`     | Jupyter notebooks in Neovim via Jupytext (fork of GCBallesteros/jupytext.nvim).               |

## Contributing

LYRD is open for contributions. If you find bugs, want to add features, or have
suggestions, open an issue or pull request.

## Acknowledgements

- [manuelestebanpr/neovim](https://github.com/manuelestebanpr/neovim) — a source
  of ideas for LYRD's Hybris (SAP Commerce) support.

## License

LYRD is released under the MIT License. See [LICENSE](LICENSE) for details.

---

LYRD(R) Neovim by Diego Ortiz. 2023-2026
