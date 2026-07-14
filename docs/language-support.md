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
- Hybris (SAP Commerce) project support — see
  [Hybris support](#hybris-sap-commerce-support) below

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

### Dart and Flutter

- flutter-tools.nvim, including its own `dartls` LSP integration
- `dart-debug-adapter` debugging support for Dart and Flutter apps
- Tree-sitter parser integration

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

## Hybris (SAP Commerce) support

- Automatic extension scanning: detects the Hybris installation
  (`HYBRIS_HOME`), reads `localextensions.xml` for active extensions,
  resolves transitive `requires-extension` dependencies, and indexes each
  extension's source paths (from `.classpath`, with heuristic fallbacks for
  `src`, `gensrc`, `web/commonwebsrc`, `backoffice/src`, `hmc/src`, etc.) and
  jars (extension `lib`/`bin`, platform `lib`, `bootstrap/bin`, `tomcat/lib`).
- Scan results are cached per project and reused on startup; a full rescan or
  cache reload is available via `LYRDJavaHybrisImportSolution`,
  `LYRDJavaHybrisReloadSolution`, and `LYRDJavaHybrisConfigureSolution`.
- Wires the scanned classpath and source paths into JDT.LS
  (`java.project.referencedLibraries`, `sourcePaths`, `java.import.exclusions`)
  so Hybris extensions are treated as one workspace instead of per-extension
  Eclipse projects.
- Hybris Type System support: indexes `*-items.xml` type, attribute, enum,
  and relation declarations to provide completion and go-to-definition in
  `items.xml`/ImpEx files, plus a type picker via `LYRDJavaHybrisFindType`.
- Lemminx XML validation and schema association for `items.xml`, `beans.xml`,
  `extensioninfo.xml`, and Spring config files scoped to each extension.
- Activates automatically for Java projects once a Hybris installation is
  detected; no manual enablement required.

## How to install language tools

Use `LYRDToolManager` (Mason) to install language servers, debuggers, and
formatters as needed.

See [installation.md](installation.md#post-installation) for setup flow and
validation.
