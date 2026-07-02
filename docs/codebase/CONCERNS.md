# Codebase Concerns

## Core Sections (Required)

### 1) Top Risks (Prioritized)

| Severity | Concern                                                | Evidence                                                  | Impact                                                  | Suggested action                                    |
| -------- | ------------------------------------------------------ | --------------------------------------------------------- | ------------------------------------------------------- | --------------------------------------------------- |
| high     | Java layer and keybinding surfaces churn often         | scan output high-churn list                               | Changes here can break common workflows                 | Keep Hybris support isolated in a new layer         |
| high     | No CI/CD pipeline detected                             | scan output                                               | Regression detection depends on manual validation       | Add or document a repeatable validation path        |
| medium   | JDTLS config is shared and runtime-driven              | `runtime/lsp/jdtls.lua`                                   | Project-specific overrides can affect all Java projects | Keep Hybris overrides additive and scoped           |
| medium   | LSP/workspace discovery depends on environment and cwd | `layers/lang/java-generator.lua`, `runtime/lsp/jdtls.lua` | Wrong JDK or workspace can misconfigure Java tooling    | Make Hybris detection explicit and user-confirmable |

### 2) Technical Debt

| Debt item                     | Why it exists                             | Where                            | Risk if ignored              | Suggested fix                                               |
| ----------------------------- | ----------------------------------------- | -------------------------------- | ---------------------------- | ----------------------------------------------------------- |
| Manual validation workflow    | Repo has no automated CI                  | scan output, `README.md`         | Regressions may slip through | Document exact Neovim validation steps for the Hybris layer |
| Shared Java runtime discovery | Multiple environment managers are scanned | `layers/lang/java-generator.lua` | False positives/duplicates   | Add project-specific filtering for Hybris                   |

### 3) Security Concerns

| Risk                                      | OWASP category (if applicable) | Evidence                         | Current mitigation                            | Gap                                                  |
| ----------------------------------------- | ------------------------------ | -------------------------------- | --------------------------------------------- | ---------------------------------------------------- |
| Environment-variable driven configuration | N/A                            | `layers/lang/java-generator.lua` | Path validation before use                    | Hybris-specific vars are not yet defined             |
| Shell-backed Git diff computation         | N/A                            | `layers/lsp.lua`                 | Uses `git` and temp files with error handling | No explicit sandboxing for external command behavior |

### 4) Performance and Scaling Concerns

| Concern                                                       | Evidence                         | Current symptom                                     | Scaling risk                                  | Suggested improvement                                 |
| ------------------------------------------------------------- | -------------------------------- | --------------------------------------------------- | --------------------------------------------- | ----------------------------------------------------- |
| Workspace/runtime discovery scans multiple Java install roots | `layers/lang/java-generator.lua` | Startup work grows with installed JDK count         | Slower startup on dev machines with many JDKs | Cache or narrow the Hybris-specific runtime selection |
| Diff-aware formatting shells out to Git and writes temp files | `layers/lsp.lua`                 | Extra work on every changed-hunk formatting request | Can be slow on large files                    | Keep Hybris-specific format hooks lightweight         |

### 5) Fragile/High-Churn Areas

| Area                       | Why fragile                                  | Churn signal | Safe change strategy                                                     |
| -------------------------- | -------------------------------------------- | ------------ | ------------------------------------------------------------------------ |
| `layers/lyrd-keyboard.lua` | Global keymaps touch many workflows          | 28 churn     | Prefer local, minimal bindings                                           |
| `layers/lyrd-commands.lua` | Command catalog drives most user actions     | 25 churn     | Avoid adding Hybris-specific commands there unless they are truly global |
| `layers/lang/java.lua`     | Java tooling orchestration is already active | 7 churn      | Add Hybris as a separate layer and keep generic Java behavior intact     |
| `layers/lsp.lua`           | Central LSP hub                              | 10 churn     | Use additive config merging and verify with health checks                |

### 6) `[ASK USER]` Questions

1. [ASK USER] Which Hybris project markers should define "this is a Hybris
   workspace"?
2. [ASK USER] Which environment variables and paths must be injected for your
   Hybris setup?
3. [ASK USER] Should the layer auto-load on detection, or only run when you
   invoke `:Load Hybris project`?
4. [ASK USER] Do you already generate Eclipse metadata/classpath for Hybris, or
   should the layer derive references some other way?

### 7) Evidence

- `docs/codebase/.codebase-scan.txt`
- `layers/lang/java.lua`
- `layers/lang/java-generator.lua`
- `runtime/lsp/jdtls.lua`
- `layers/lsp.lua`
