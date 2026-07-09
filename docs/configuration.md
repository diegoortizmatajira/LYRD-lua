# Configuration

[Back to README](../README.md)

## Local configuration file

User customizations belong in:

```bash
~/.local/share/nvim/lyrd/lyrd-local.lua
```

You can open it with `LYRDEditLocalConfig`.

## Skipping layers

Disable features you do not use to reduce startup and runtime overhead:

```lua
return {
 skip_layers = {
  "LYRD.layers.ai-dev",
  "LYRD.layers.docker",
  "LYRD.layers.kubernetes",
 },
}
```

Common optional layers:

- `LYRD.layers.ai-dev`
- `LYRD.layers.docker`
- `LYRD.layers.kubernetes`
- `LYRD.layers.repl`
- `LYRD.layers.grammar`
- `LYRD.layers.static-website`
- `LYRD.layers.lang.java`
- `LYRD.layers.lang.dotnet`
- `LYRD.layers.lang.rust`

## Keybinding customization

Override or add mappings in your local config:

```lua
vim.keymap.set("n", "<your-key>", "<your-command>", { desc = "Your description" })
```

See [keyboard-workflow.md](keyboard-workflow.md) and [commands.md](commands.md)
for defaults.

## AI provider setup

LYRD supports multiple AI providers (Copilot, Codeium, TabNine). Configure
provider behavior through local overrides in AI layer settings.

## Themes

- `LYRDApplyNextTheme` cycles themes.
- `LYRDApplyCurrentTheme` persists current theme.

## Project-specific settings

Use a project-level `.nvim.lua` for project-only overrides (tasks, vars,
commands, build settings).

## Updating LYRD

```bash
cd ~/.config/nvim/lua/LYRD
git pull
```

Then in Neovim:

1. Run `LYRDPluginsUpdate`.
2. Restart Neovim.
