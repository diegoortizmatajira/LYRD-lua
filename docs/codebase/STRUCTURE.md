# Codebase Structure

## Core Sections (Required)

### 1) Top-Level Map

| Path | Purpose | Evidence |
|------|---------|----------|
| `root-init.lua` | Neovim entry bootstrap | `root-init.lua` |
| `init.lua` | Layer registration and order | `init.lua` |
| `shared/` | Common setup/helpers | `shared/setup.lua`, `shared/declarative_layer.lua` |
| `layers/` | Core feature layers | `layers/lang/java.lua`, `layers/lsp.lua`, `layers/test.lua` |
| `layers/lang/` | Language-specific layers and generators | `layers/lang/java.lua`, `layers/lang/java-generator.lua` |
| `runtime/` | Neovim runtime files, including LSP configs | `runtime/lsp/jdtls.lua` |
| `docs/` | User-facing docs | `docs/overview.md`, `docs/language-support.md` |
| `tests/` | Neovim Lua specs | `tests/java_generator_spec.lua` |
| `configs/` | External tool configs | repo tree |
| `skeletons/` | File templates/snippets | repo tree |
| `snippets/` | Snippet definitions | repo tree |
| `test` | Shell entrypoint for launching Neovim | `test` |
| `health.lua` | Custom health checks | `health.lua` |

### 2) Entry Points

- Main runtime entry: `root-init.lua`
- Secondary entry points (worker/cli/jobs): `test`
- How entry is selected (script/config): `root-init.lua` requires `LYRD.init`; the README instructs linking `root-init.lua` to `~/.config/nvim/init.lua`

### 3) Module Boundaries

| Boundary | What belongs here | What must not be here |
|----------|-------------------|------------------------|
| `shared/` | Cross-layer setup, helpers, shared integrations | Layer-specific command wiring |
| `layers/` | Feature layers, plugin registration, commands, keymaps | Low-level runtime bootstrapping |
| `layers/lang/` | Language-specific support and generators | Generic UI or unrelated workflow logic |
| `runtime/lsp/` | Per-server LSP config tables | UI behavior or layer registration |
| `tests/` | Spec files and mocks | Production layer logic |

### 4) Naming and Organization Rules

- File naming pattern: kebab-case and domain-based names (`java.lua`, `java-generator.lua`, `pascal_ls.lua`, `jdtls.lua`)
- Directory organization pattern: layer-based, with language support grouped under `layers/lang/`
- Import aliasing or path conventions: repo-local modules use `LYRD.*` require paths

### 5) Evidence

- `init.lua`
- `root-init.lua`
- `shared/setup.lua`
- `layers/lang/java.lua`
- `runtime/lsp/jdtls.lua`
- `tests/java_generator_spec.lua`
