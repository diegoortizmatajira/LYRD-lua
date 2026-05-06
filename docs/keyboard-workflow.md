# Keyboard-Driven Workflow

[Back to README](../README.md)

LYRD is built to keep your hands on the keyboard and minimize context switching.

## Leader keys

- `,` - fast-access leader for frequent actions.
- `<Space>` - structured feature menus.

## Main groups under `<Space>`

- `<Space>b` - buffer operations
- `<Space>c` - code/run/build actions
- `<Space>d` - debugging
- `<Space>g` - Git
- `<Space>p` - preferences and tooling
- `<Space>s` - search/navigation
- `<Space>t` - testing
- `<Space>r` - tasks and REPL

## Common quick actions

- `,f` - format current buffer
- `,x` - run selection
- `,X` - run file
- `<Space>pd` - update LYRD distro
- `,c` - close buffer
- `,[` / `,]` - previous/next buffer
- `,<Space>` - clear search highlights

## Function keys

- `F2` file tree
- `F3` test summary
- `F4` code outline
- `F5` debug continue/start
- `F9` toggle breakpoint
- `F10` step over
- `F11` step into
- `F12` step out

## Navigation and LSP shortcuts

- `<Ctrl-p>` find files
- `<Ctrl-t>` search in files
- `<Ctrl-f>` resume search
- `gd` go to definition
- `gr` find references
- `gi` go to implementation
- `gt` go to type definition
- `K` hover documentation
- `<Alt-Enter>` or `<Ctrl-.>` code actions
- `<Ctrl-r><Ctrl-r>` rename symbol

## Example loop

1. `<Ctrl-p>` open file.
2. `<Space>so` jump to symbol.
3. Edit code.
4. `,f` format.
5. `<Space>tt` run tests.
6. `<Space>gs` review Git status.

## Learn incrementally

Press `,` or `<Space>` and pause to open the key-hint popup. LYRD is designed
for gradual discovery.

For the full command and keybinding catalog, see [commands.md](commands.md).
