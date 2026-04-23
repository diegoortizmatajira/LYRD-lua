# LYRD (Layered) - A Complete Development Environment for Neovim

LYRD (Layered Neovim) turns Neovim into a modern, IDE-like development
environment with a modular architecture, strong language tooling, integrated
testing/debugging, and keyboard-first workflows.

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

## Quick IDE Comparison (for new users)

| Area                        | LYRD                                                       | VS Code                            | JetBrains IDEs                      | Visual Studio                   |
| --------------------------- | ---------------------------------------------------------- | ---------------------------------- | ----------------------------------- | ------------------------------- |
| Core model                  | Neovim-first, layer-based, keyboard-driven                 | Extension-based editor             | Full IDE suites per stack           | Full IDE focused on .NET/C++    |
| Out-of-box dev workflow     | Strong defaults with integrated testing, debug, tasks, Git | Good base, usually extension-heavy | Very strong, integrated by product  | Very strong for Microsoft stack |
| Customization depth         | Very high (Lua + layers)                                   | Very high (settings + extensions)  | Moderate to high (plugins/settings) | Moderate (extensions/settings)  |
| Terminal/SSH-first workflow | Native strength                                            | Good                               | Available, less terminal-native     | Available, less terminal-native |
| Performance profile         | Lightweight, fast startup and navigation                   | Lightweight to medium              | Medium to heavy (feature-rich)      | Medium to heavy (feature-rich)  |

### Features at a glance

LYRD includes integrated LSP tooling, formatting, testing, debugging, Git
workflows, task automation, AI-assisted coding, REST client, database tooling,
container/Kubernetes support, and keyboard-first discovery workflows.

### Supported language ecosystems (high level)

Python, JavaScript/TypeScript, Java, .NET (C#/F#/VB.NET), Go, Rust, C/C++,
Kotlin, Bash, PHP, Pascal, LaTeX, SQL, plus common formats like
JSON/YAML/TOML/XML, Markdown, CMake, Protocol Buffers, and CSV/TSV.

For full details, see [docs/language-support.md](docs/language-support.md).

## Contributing

LYRD is open for contributions. If you find bugs, want to add features, or have
suggestions, open an issue or pull request.

## License

LYRD is released under the MIT License. See `LICENSE` for details.

---

LYRD(R) Neovim by Diego Ortiz. 2023-2026
