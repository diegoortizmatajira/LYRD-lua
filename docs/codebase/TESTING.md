# Testing Patterns

## Core Sections (Required)

### 1) Test Stack and Commands

- Primary test framework: Neotest with Lua specs (`describe` / `it`); Busted-style assertions
- Assertion/mocking tools: plain Lua `assert`, `vim.*` function stubbing, Neotest adapters
- Commands:

```bash
./test
:LYRDTestSuite
:LYRDTestFile
:LYRDTestFunc
:LYRDTestCoverageSummary
```

### 2) Test Layout

- Test file placement pattern: `tests/`
- Naming convention: `*_spec.lua`
- Setup files and where they run: Neotest is configured in `layers/test.lua`; the `test` shell script launches Neovim with `init.lua`

### 3) Test Scope Matrix

| Scope | Covered? | Typical target | Notes |
|-------|----------|----------------|-------|
| Unit | yes | generator/helpers | Most specs exercise pure helper logic |
| Integration | partial | Treesitter / Neotest / LSP-adjacent code | Some tests attach parsers or use runtime APIs |
| E2E | no evidence | full editor workflows | `[TODO]` |

### 4) Mocking and Isolation Strategy

- Main mocking approach: replace `vim.fn`, `vim.ui`, and `vim.notify` functions and restore them after each test
- Isolation guarantees: tests create scratch buffers where needed and clean them up in `after_each`
- Common failure mode in tests: brittle assumptions about parser availability; some specs skip when a treesitter parser is absent

### 5) Coverage and Quality Signals

- Coverage tool + threshold: `nvim-coverage`; threshold `[TODO]`
- Current reported coverage: `[TODO]`
- Known gaps/flaky areas: no automated CI evidence, and some specs depend on optional parsers/adapters

### 6) Evidence

- `layers/test.lua`
- `tests/java_generator_spec.lua`
- `tests/go_generator_spec.lua`
- `tests/dotnet_generator_spec.lua`
- `tests/treesitter_spec.lua`
- `tests/markdown_format_spec.lua`
- `test`

