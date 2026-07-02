# Architecture

## Core Sections (Required)

### 1) Architectural Style

- Primary style: layered, stage-based initialization
- Why this classification: layers are registered in `init.lua`, then executed
  through `plugins()`, `preparation()`, `settings()`, `keybindings()`, and
  `complete()` in `shared/setup.lua`
- Primary constraints: load order matters; runtime LSP configs are enabled after
  layer setup; shared command behavior must remain consistent across layers

### 2) System Flow

```text
root-init.lua -> init.lua -> shared/setup.lua -> layer lifecycle -> runtime/lsp config -> user commands/keymaps
```

1. `root-init.lua` loads `LYRD.init`.
2. `init.lua` registers the ordered layer list.
3. `shared/setup.lua` filters layers, bootstraps Lazy.nvim, and executes layer
   lifecycle stages.
4. Shared layers like `layers/lsp.lua` register tool installation, formatting,
   and command handlers.
5. `runtime/lsp/jdtls.lua` supplies the JDTLS server config used when Java LSP
   is enabled.
6. Java layers add filetype-specific commands and runtime selection logic on top
   of the shared Java baseline.

### 3) Layer/Module Responsibilities

| Layer or module                  | Owns                                                | Must not own                      | Evidence                         |
| -------------------------------- | --------------------------------------------------- | --------------------------------- | -------------------------------- |
| `shared/setup.lua`               | Bootstrap, layer loading, lifecycle orchestration   | Language-specific behavior        | `shared/setup.lua`               |
| `layers/lsp.lua`                 | Mason, conform, none-ls, LSP command wiring         | Per-language feature decisions    | `layers/lsp.lua`                 |
| `layers/lang/java.lua`           | Java plugin/tooling setup and Java command mappings | Hybris-specific project bootstrap | `layers/lang/java.lua`           |
| `runtime/lsp/jdtls.lua`          | JDTLS process/config payload                        | UI or command registration        | `runtime/lsp/jdtls.lua`          |
| `layers/lang/java-generator.lua` | Java runtime discovery and package helpers          | Generic layer lifecycle           | `layers/lang/java-generator.lua` |

### 4) Reused Patterns

| Pattern                   | Where found                                       | Why it exists                                        |
| ------------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| Declarative layer wrapper | `shared/declarative_layer.lua`                    | Reduces boilerplate for language layers              |
| Command registry          | `layers/commands.lua`, `layers/lyrd-commands.lua` | Keeps keymaps and filetype actions uniform           |
| Runtime config table      | `runtime/lsp/*.lua`                               | Lets `vim.lsp.enable()` use server-specific settings |
| Environment discovery     | `layers/lang/java-generator.lua`                  | Finds installed JDKs from common managers            |

### 5) Known Architectural Risks

- Layer order coupling: changing the order in `init.lua` can affect plugin
  setup, command registration, and LSP enablement.
- Project-specific LSP behavior is centralized in shared Java config, so Hybris
  customization needs to avoid breaking generic Java projects.

### 6) Evidence

- `root-init.lua`
- `init.lua`
- `shared/setup.lua`
- `shared/declarative_layer.lua`
- `layers/lsp.lua`
- `runtime/lsp/jdtls.lua`
