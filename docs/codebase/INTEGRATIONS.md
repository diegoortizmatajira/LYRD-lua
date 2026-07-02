# External Integrations

## Core Sections (Required)

### 1) Integration Inventory

| System | Type (API/DB/Queue/etc) | Purpose | Auth model | Criticality | Evidence |
|--------|---------------------------|---------|------------|-------------|----------|
| Mason registries | Tool/package registry | Install LSPs, formatters, debuggers, test adapters | Network download / local package metadata | High | `layers/lsp.lua` |
| JDTLS | Local language server | Java editor intelligence and runtime config | Local process | High | `runtime/lsp/jdtls.lua` |
| Neotest | Test orchestration | Run file/suite/function tests | Local process | High | `layers/test.lua` |
| Git CLI | VCS / shell integration | Diff-aware formatting and repo inspection | Local repo access | Medium | `layers/lsp.lua` |
| Overseer | Local task runner | Java/Maven/Gradle task execution | Local process | Medium | `layers/lang/java.lua`, `layers/lang/dotnet.lua` |

### 2) Data Stores

| Store | Role | Access layer | Key risk | Evidence |
|-------|------|--------------|----------|----------|
| Neovim cache/state dirs | LSP workspace, plugin state, lockfile storage | `shared/setup.lua`, `runtime/lsp/jdtls.lua` | Stale workspace or state mismatch | `shared/setup.lua`, `runtime/lsp/jdtls.lua` |

### 3) Secrets and Credentials Handling

- Credential sources: environment variables and local config file (`~/.local/share/nvim/lyrd/lyrd-local.lua`)
- Hardcoding checks: no committed secret store detected in the scan output
- Rotation or lifecycle notes: `[TODO]`

### 4) Reliability and Failure Behavior

- Retry/backoff behavior: none found
- Timeout policy: mostly implicit; failures are surfaced through `vim.notify`/`pcall`
- Circuit-breaker or fallback behavior: limited fallbacks, such as runtime discovery falling back to common JDK locations

### 5) Observability for Integrations

- Logging around external calls: yes, mainly `vim.notify`
- Metrics/tracing coverage: none found
- Missing visibility gaps: no centralized metrics, no integration-specific dashboards, and no automated pipeline evidence in the scan

### 6) Evidence

- `layers/lsp.lua`
- `runtime/lsp/jdtls.lua`
- `layers/test.lua`
- `layers/lang/java.lua`
- `shared/setup.lua`

