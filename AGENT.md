# Agent Guidelines for nix-config

## Repository overview

This is a Nix flake managing macOS (nix-darwin) and Linux (standalone home-manager) configurations. It uses **flake-parts** for per-system attribute generation.

### Architecture

```
flake.nix                  # Entry point: inputs, overlays, per-system apps/checks
modules/
  darwin/                  # nix-darwin system modules (macOS-only)
  home-manager/
    home.nix               # Import hub — all HM modules listed here
    core.nix               # User identity, XDG, session vars
    packages.nix           # All packages, organised by category
    programs.nix           # programs.* module configs (bat, fzf, etc.)
    shell.nix              # Shell umbrella (imports zsh.nix, configures bash/fish)
    zsh.nix                # Zsh plugins, aliases, initContent
    git.nix                # Git, lazygit, delta, gh
    neovim.nix             # LazyVim config
    claude.nix             # Claude Code settings + MCP servers
    opencode.nix           # OpenCode AI config
    lspmux.nix             # Shared LSP instances between editors/agents
    secrets.nix            # SOPS-nix secret declarations
    stylix.nix             # System-wide Tokyo Night theming
    ...
config/                    # Vendored application configs (nvim, lazygit, etc.)
pkgs/                      # Custom Nix package definitions
scripts/                   # Utility scripts
secrets/                   # SOPS-encrypted YAML
docs/                      # Architecture diagrams
```

### Key patterns

- **Platform branching**: Use `lib.mkIf isDarwin` / `lib.mkIf isLinux` inside modules, not separate files.
- **Packages go in packages.nix**: Organised by category with section headers.
- **Programs go in programs.nix**: Anything using `programs.<name>.enable`.
- **Secrets**: Managed via sops-nix. Decrypted values cached to `~/.cache/sops-secrets/decrypted.json` for fast access by MCP wrappers.
- **Theming**: Stylix applies Tokyo Night globally. Individual tool themes should defer to Stylix where possible.
- **Pre-commit hooks**: Native Nix via git-hooks.nix (alejandra, deadnix, statix, stylua, taplo, prettier, gitleaks).
- **Formatting**: `nix run .#treefmt` for unified formatting.

## Nix conventions

- Format with **alejandra** (not nixfmt).
- Use `lib.mkIf` / `lib.mkMerge` for conditional config, not `if-then-else` at the module level.
- Prefer `pkgs.writeShellScript` over `pkgs.writeShellScriptBin` for non-PATH scripts.
- Pin flake inputs with `follows` to avoid duplicate nixpkgs.
- Use `lib.optionals` for conditional list elements, `lib.optionalAttrs` for conditional attrsets.

## Git workflow

- Commit messages: concise, imperative, explain the "why" not just the "what".
- All commits pass pre-commit hooks (alejandra, deadnix, statix, gitleaks, prettier).
- Use `git mv` for tracked files.
- Do not commit secrets, `.env` files, or credentials.

## Rust guidelines

- Use nix-provided rust toolchain exclusively (not rustup).
- Prefer `expect()` over `unwrap()` with a concise reason.
- Use `.context()` on every `?` propagation when using eyre/anyhow.
- Add dependencies with `cargo add`.
- Use `clippy-mantis` alias for strict linting.

## Code style

- Keep modules focused: one concern per file.
- Add section headers (`# ═══...`) to group related config within a file.
- Document non-obvious trade-offs with inline comments.
- Avoid over-abstraction — three similar lines beats a premature helper.
- Run `shellcheck` on shell scripts.

## SESSION.md

While working, if you encounter bugs, missing features, or oddities, add a concise note to `SESSION.md` to defer them. Do not write accomplishments into that file.

## Common commands

```bash
# Build without switching
nix run .#darwin-build

# Build and switch (macOS)
nix run .#darwin-switch

# Build and switch (Linux)
nix run .#home-switch

# Update all flake inputs
nix flake update

# Format everything
nix run .#treefmt

# Check for issues
nix flake check

# Search nixpkgs
nix search nixpkgs <package>

# Enter dev shell with all tools
nix develop
```
