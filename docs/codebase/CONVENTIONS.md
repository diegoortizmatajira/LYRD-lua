# Coding Conventions

## Core Sections (Required)

### 1) Naming Rules

| Item | Rule | Example | Evidence |
|------|------|---------|----------|
| Files | Kebab-case / domain-based Lua files | `java.lua`, `java-generator.lua`, `jdtls.lua` | `layers/lang/java.lua`, `runtime/lsp/jdtls.lua` |
| Functions/methods | Snake_case is common for locals and module methods | `get_runtimes`, `load_if_should_be_loaded`, `start_tooling` | `layers/lang/java-generator.lua`, `shared/setup.lua`, `layers/lang/java.lua` |
| Types/interfaces | PascalCase LuaDoc aliases/classes | `JavaRuntime`, `Command` | `layers/lang/java-generator.lua`, `layers/commands.lua` |
| Constants/env vars | Upper snake case for environment variables | `JAVA_HOME`, `SDKMAN_DIR` | `layers/lang/java-generator.lua` |

### 2) Formatting and Linting

- Formatter: Stylua (`stylua.toml`)
- Linter: Selene (`selene.toml`)
- Most relevant enforced rules: tabs for indentation, 120-column width, Lua 5.1 + Neovim globals, `sort_requires`
- Run commands: `[TODO]` (no dedicated repo-wide lint script is checked in)

### 3) Import and Module Conventions

- Import grouping/order: local `require(...)` statements appear at the top of modules
- Alias vs relative import policy: repo-local namespaces use `LYRD.*`; no relative module paths are used
- Public exports/barrel policy: modules export a single table/object rather than a barrel file

### 4) Error and Logging Conventions

- Error strategy by layer: `pcall` around dynamic hooks, warnings when a layer or config cannot be loaded, and early returns for invalid inputs
- Logging style and required context fields: `vim.notify` with `vim.log.levels.*`; messages usually include the layer or operation name
- Sensitive-data redaction rules: `[TODO]`; runtime secrets are expected to stay in environment/local config, not tracked files

### 5) Testing Conventions

- Test file naming/location rule: `tests/*_spec.lua`
- Mocking strategy norm: save original `vim.*` functions, replace them inside the test, and restore in `after_each`
- Coverage expectation: `[TODO]` (no explicit threshold found)

### 6) Evidence

- `stylua.toml`
- `selene.toml`
- `.editorconfig`
- `layers/lang/java-generator.lua`
- `shared/setup.lua`
- `tests/java_generator_spec.lua`

