# Installation

[Back to README](../README.md)

## Prerequisites

- Neovim 0.11.0+
- Git
- Nerd Font (recommended for icons)
- ripgrep
- fd (optional, recommended)
- Node.js
- Python 3

## Basic Installation

1. Backup existing Neovim setup (optional but recommended):

    ```bash
    mv ~/.config/nvim ~/.config/nvim.backup
    mv ~/.local/share/nvim ~/.local/share/nvim.backup
    mv ~/.local/state/nvim ~/.local/state/nvim.backup
    mv ~/.cache/nvim ~/.cache/nvim.backup
    ```

2. Clone LYRD:

    ```bash
    git clone https://github.com/diegoortizmatajira/LYRD-lua.git ~/.config/nvim/lua/LYRD
    ```

3. Link init entrypoint:

    ```bash
    ln -s ~/.config/nvim/lua/LYRD/root-init.lua ~/.config/nvim/init.lua
    ```

4. Launch Neovim:

    ```bash
    nvim
    ```

5. Wait for first-time plugin installation, then restart Neovim.

## Post-Installation

1. Open tool manager with `LYRDToolManager`.
2. Install required tools for your languages.
3. Run health checks:

    ```vim
    :checkhealth LYRD
    ```

Common tools:

- Python: `basedpyright`, `ruff`, `debugpy`
- JavaScript/TypeScript: `typescript-language-server`, `prettier`
- Java: `jdtls`, `java-debug-adapter`
- Bash: `bash-language-server`, `shfmt`, `shellcheck`
- Environment files: `dotenv-linter`
- Ruby: `solargraph`, `rubocop`
- PHP: `intelephense`, `laravel-ls`, `php-cs-fixer`, `phpcs`
- Nix: `nil`, `alejandra`
- Groovy: `groovy-language-server`, `npm-groovy-lint`
- Go: `gopls`, `delve`
- Rust: `rust-analyzer`, `codelldb`
- C/C++: `clangd`, `clang-format`

For local customization after install, continue with
[configuration.md](configuration.md).
