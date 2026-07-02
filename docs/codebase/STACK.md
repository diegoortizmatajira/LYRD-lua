# Technology Stack

## Core Sections (Required)

### 1) Runtime Summary

| Area | Value | Evidence |
|------|-------|----------|
| Primary language | Lua | `init.lua`, `layers/*.lua` |
| Runtime + version | Neovim 0.11.0+ | `docs/installation.md` |
| Package manager | Lazy.nvim for plugins; Mason for tool installs | `shared/setup.lua`, `layers/lsp.lua` |
| Module/build system | No standalone build system; runtime bootstraps through `root-init.lua` -> `init.lua` -> `shared/setup.lua` | `root-init.lua`, `init.lua`, `shared/setup.lua` |

### 2) Production Frameworks and Dependencies

| Dependency | Version | Role in system | Evidence |
|------------|---------|----------------|----------|
| lazy.nvim | [TODO] | Plugin manager | `shared/setup.lua` |
| nvim-lspconfig | [TODO] | LSP client config | `layers/lsp.lua` |
| mason.nvim / mason-lspconfig.nvim | 2.* | Tool and server installation | `layers/lsp.lua` |
| none-ls.nvim / none-ls-extras.nvim | [TODO] | Formatter/diagnostic integration | `layers/lsp.lua` |
| conform.nvim | [TODO] | Formatting orchestration | `layers/lsp.lua` |
| nvim-jdtls | [TODO] | Java LSP integration | `layers/lang/java.lua`, `runtime/lsp/jdtls.lua` |
| neotest | [TODO] | Test runner orchestration | `layers/test.lua` |

### 3) Development Toolchain

| Tool | Purpose | Evidence |
|------|---------|----------|
| Stylua | Lua formatting | `stylua.toml` |
| Selene | Lua linting | `selene.toml` |
| EditorConfig | Editor formatting baseline | `.editorconfig` |
| markdownlint | Markdown style guidance | `.markdownlint.jsonc` |

### 4) Key Commands

```bash
./test
:checkhealth LYRD
:LYRDTestSuite
:LYRDTestFile
:LYRDTestFunc
```

### 5) Environment and Config

- Config sources: `init.lua`, `root-init.lua`, `shared/setup.lua`, `stylua.toml`, `selene.toml`, `.editorconfig`, `.markdownlint.jsonc`
- Required env vars: `[TODO]` (project-specific runtime vars are read at runtime, e.g. `JAVA_HOME`, `SDKMAN_DIR`, `ASDF_DATA_DIR`, `JABBA_HOME`, `JENV_ROOT`)
- Deployment/runtime constraints: Neovim must be launched with the LYRD init chain; plugin/tool state is installed at runtime via Lazy.nvim and Mason.

### 6) Evidence

- `root-init.lua`
- `init.lua`
- `shared/setup.lua`
- `layers/lsp.lua`
- `layers/lang/java.lua`
- `layers/test.lua`

