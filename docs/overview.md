# LYRD Overview

[Back to README](../README.md)

## What is LYRD?

LYRD (Layered Neovim) is a curated Neovim distribution focused on software
development. It combines language tooling, testing, debugging, Git workflows,
and automation into one consistent setup.

It is designed to provide:

- A productive default experience for new users.
- A modular, maintainable architecture for advanced users.
- A unified command model across many languages and ecosystems.

## Why use LYRD?

- **Faster onboarding**: skip weeks of plugin research and configuration.
- **Less context switching**: coding, testing, debugging, Git, and tasks are in
  one place.
- **Keyboard-first productivity**: optimized for flow and repeatable workflows.
- **Remote-friendly**: terminal-based development works over SSH, in containers,
  and on servers.

## Architecture: the Layer model

LYRD is built from independent **layers**. Each layer owns a capability (for
example: Git, debug, test, a language, or UI behavior).

Key properties:

- **Modular**: features are isolated and easier to maintain.
- **Composable**: layers are loaded in an explicit order.
- **Configurable**: users can skip selected layers from local config.
- **Consistent**: commands map to common workflows across languages.

## Layer lifecycle

Across the configured layer list, LYRD executes these lifecycle stages:

1. `plugins()` - plugin registration.
2. `preparation()` - tools/adapters/parsers preparation.
3. `settings()` - configuration and command mapping.
4. `keybindings()` - keymap registration.
5. `complete()` - final activation and runtime setup.

This staged lifecycle keeps cross-layer behavior predictable and reduces
initialization conflicts.

## Core entry points

- Bootstrap chain: `root-init.lua` -> `init.lua` -> `shared/setup.lua`.
- Command model: `layers/lyrd-commands.lua` and `layers/commands.lua`.
- LSP/tooling hub: `layers/lsp.lua`.

For feature-level details, see [features.md](features.md),
[panels.md](panels.md), and [language-support.md](language-support.md).
