# Language Support

[Back to README](../README.md)

LYRD supports many languages through declarative layers that combine LSP,
formatting, testing, debugging, and task workflows.

## Primary languages

### Python

- Basedpyright/Pyright + Ruff
- pytest/unittest integration
- debugpy support
- Jupyter/REPL workflows

### JavaScript/TypeScript and web

- VTSLS, Vue LS, Angular LS
- React/Vue/Angular/Svelte workflows
- Jest/Vitest support
- Prettier integration
- i18n diagnostics and local dev server workflows

### Java

- JDT.LS + Java debug adapter
- Maven/Gradle support
- JUnit/TestNG test workflows
- Spring Boot tooling support
- Runtime selection via `LYRDCodeSelectEnvironment` (`:JdtSetRuntime`)

### .NET (C#, F#, VB.NET)

- Roslyn via easy-dotnet
- VSTest integration
- netcoredbg support
- CSharpier and scaffolding templates

### Go

- gopls + delve
- go test integration
- gofmt/goimports formatting

### Rust

- rust-analyzer + codelldb/lldb
- cargo test/build workflows
- crate/dependency tooling

### C and C++

- clangd + lldb/codelldb
- CTest support
- clang-format integration

## Additional languages and formats

- Kotlin, Bash, Ruby, PHP, Nix, Groovy, Pascal, LaTeX, SQL
- Lua, Markdown
- JSON, YAML, TOML, XML
- CMake
- Protocol Buffers/gRPC
- CSV/TSV

## Ruby

- Solargraph LSP support
- RuboCop formatting and diagnostics
- Tree-sitter parser integration

## PHP

- Intelephense and Laravel LS support
- `php-cs-fixer` formatting
- `phpcs` diagnostics
- Tree-sitter parser integration

## Nix

- `nil_ls` language server support (`nil`)
- Alejandra formatting

## Groovy

- `groovyls` language server support (`groovy-language-server`)
- `npm-groovy-lint` formatting and diagnostics
- Jenkinsfile diagnostics support
- Tree-sitter parser integration

## Bash

- `bashls` language server support
- `shfmt` formatting
- `shellcheck` diagnostics via Bash language tooling
- `LYRDCodeRun` support for running the current shell script as a task

## Environment files (`.env` and variants)

- Filetype support for `.env`, `.env.*`, `env`, and related env-style files
- `dotenv-linter` formatting/diagnostics integration
- Environment variable value masking and peek workflows via shelter/ecolog tooling

## SQL highlights

- Multi-dialect SQL linting/formatting support
- Database-aware query execution
- Connection-aware dialect selection
- In-editor result browsing

## How to install language tools

Use `LYRDToolManager` (Mason) to install language servers, debuggers, and
formatters as needed.

See [installation.md](installation.md#post-installation) for setup flow and
validation.
