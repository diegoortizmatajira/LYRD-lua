# Troubleshooting and Help

[Back to README](../README.md)

## Common issues

### Plugins not loading

- Run `:Lazy sync`
- Check `:checkhealth lazy`

### Language features not working

- Install the missing server/tool via `LYRDToolManager`
- Check active LSPs with `:LspInfo`
- Run `:checkhealth lsp`

### Performance issues

- Skip unused layers in local config
- Disable optional heavy features (for example AI) if not needed
- Large files may auto-disable some features

### Icons not showing

- Install and activate a Nerd Font in your terminal
- Run `:checkhealth` and inspect icon/font checks

## Getting help inside LYRD

- `LYRDSearchKeyMappings` - keymaps for current context
- `LYRDSearchCommands` - command catalog
- `LYRDToolManager` - manage tooling
- `:checkhealth LYRD` - full LYRD diagnostics

## Learning path

1. File navigation and search
2. Code navigation and LSP actions
3. Build/run/test loops
4. Git workflows
5. Debugging workflows

Use which-key discovery often: press `,` or `<Space>` and wait for the menu
popup.
