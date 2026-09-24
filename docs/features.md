# Core Features

[Back to README](../README.md)

## Smart editor defaults

- Persistent undo and cursor position restore.
- Project-aware indentation behavior.
- Minimal visual noise with practical defaults.
- System clipboard integration.
- Clipboard cleanup helpers (trim/unquote), plus fast path/code-copy commands
  and a Markdown-to-plain-text copy command that strips Markdown syntax.

## Interface and feedback

- Informative status line and startup screen.
- Clear notifications and command palette UX.
- Floating terminal support and focus mode.
- Inline color previews and diagnostics UI.

## Code intelligence

- LSP-based completion, diagnostics, navigation, and hover docs.
- Refactoring helpers and code actions.
- Automatic formatting integration.
- Diff-aware formatting for changed sections only, keeping review diffs small.

## Search and navigation

- Fuzzy file finder and live grep, with filename-first path display for
  quick scanning of deeply nested results.
- Symbol navigation and code outline.
- TODO/FIXME discovery and reusable macro search.
- Scratch files: create, open, search, and delete workspace-scoped scratch
  notes, plus migrating scratches from one workspace scope to another.
- Clipboard scratch file: open a persistent global scratch note, yank a
  visual selection into it, and paste its contents back into a buffer.

## Git workflow

- Visual Git tools for status, commit, branch, diff, and conflict resolution.
- Gutter and blame annotations.
- Worktree and GitHub workflow support, including GitHub PR creation with UI
  prompts (base branch, draft status, title) and a toggleable GitHub
  dashboard (`gh dash`).
- Git Flow init/start/finish run in an external terminal that stays open on
  exit so the outcome is visible.
- Patch export/import: create `.patch` files from recent or unpushed commits,
  or from currently staged/unstaged changes, and apply a single patch file or
  a whole directory of patches, with interactive prompts for commit count,
  output file/directory, and target ref/file.

## Testing and debugging

- Test by function, file, or suite with result visualization.
- Debugger integrations for major languages.
- Debug UI with scopes, stack, breakpoints, watches, and REPL.

## Task automation

- Unified task execution for build, test, run, and deployment steps.
- `.vscode/tasks.json` interoperability.
- History, output visibility, and parallel execution.
- Tmux strategy for long-running tasks: runs a task in a detachable tmux
  session and reattaches to it, with automatic (silent) and on-demand
  (`LYRDTasksRecoverTmux`) recovery of tasks left running from a previous
  session.

## AI-assisted development

- Inline completions and chat/edit workflows.
- Multiple provider options (Copilot, Codeium, TabNine).
- CLI AI tool integration via Sidekick + tmux.

## Templates and scaffolding

- Language-specific code snippets and templates.
- Smart placeholders and quick expansion.
- Faster bootstrapping for common patterns.

## Cloud, containers, and pipelines

- Docker/Compose workflows from the editor, including support for a custom
  `docker-compose` file path, "up (force recreate)", and "logs (follow)".
- Database backup/restore against a running Docker container, picked via a
  Telescope container list (`LYRDDatabaseBackup`/`LYRDDatabaseRestore`).
- Compose `image:` property: code action and completion to pick a local
  Docker image, filtered by the current value.
- Kubernetes manifests and Helm support.
- CI/CD YAML language server support for GitHub/GitLab/Azure.

## Extra workflows

- Text encoding/decoding helpers for selected content (URL, Base64, UU, JWT decode).
- REPL/notebook workflows (Python-focused).
- REST API request execution from `.http`/`.rest`, plus generating `.http`
  files from an OpenAPI spec (`LYRDCodeGenerateHttpFromOpenApi`, via
  `httpgenerator`).
- Database browsing/query execution.
- Environment file workflows for `.env`-style files with linting and value masking support.
- Grammar checking for docs/comments/strings.
- Static-site (Hugo) workflows and dev-server support: create new
  pages/articles, build, serve (with drafts), and list draft content from the
  `Website` menu.
- Secret scanning integration.
- Regex debugging via an embedded `rgx` terminal (`LYRDRegexTest`), including
  running it against a visual selection.
- Tmux integration and Neovide compatibility.
- VSCode-compatible layer mode.

For panel-level UX and screenshots, see [panels.md](panels.md).
