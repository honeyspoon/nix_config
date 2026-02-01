# Changelog

All notable changes to this Nix configuration will be documented in this file.

## [unreleased]

### Bug Fixes

- Fix nix-darwin migration and improve checks
- Fix darwin-switch flake path under sudo
- Fix zsh PATH ordering
- Fix Linux home-manager to allow unfree packages

The standalone home-manager configuration for Linux was failing
because claude-code requires allowUnfree. Changed from using
legacyPackages to importing nixpkgs with config.allowUnfree = true.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
- Fix tmux on ghostty for Linux (missing terminfo)

- Add TERM fallback to xterm-256color when ghostty terminfo is missing
- Handle both "ghostty" and "xterm-ghostty" TERM values
- Apply fix to both bash and zsh init scripts
- Add ghostty terminal override to tmux config for true color support
- Fix Stylix and Ghostty for Linux

- Fix ghostty: use nixpkgs package on Linux (was null causing systemd error)
- Fix stylix: disable ghostty target (conflicts with package=null)
- Fix stylix: generate solid color wallpaper (remote URL was 404)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

### Features

- Add image to README file
- Add wrapped apps for LazyVim and OpenCode
- Add sops-nix secrets scaffolding
- Add gitleaks secret scanning hook
- Add encrypted secrets file
- Update nix config: hostname, zsh fixes, new modules

- Change host from abder-macbook to workmbp to match actual hostname
- Fix zsh backward search (Ctrl-R) by using zvm_after_init hook
- Fix dotDir to use relative path (.config/zsh)
- Add zen-browser module with privacy extensions
- Add claude.nix for Claude Code settings
- Add opencode-mystatus plugin and expand opencode config
- Add nix-index-database and comma for package discovery
- Switch to nixpkgs-25.11-darwin and FlakeHub URLs
- Add Determinate Systems cache
- Add new homebrew packages (opencode, arc)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
- Update zsh history, fzf bindings, and Claude settings
- Add agent-browser package and disable OpenCode prompts
- Add cross-platform support for macOS and Linux

- Support 4 systems: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- Add homeConfigurations for standalone home-manager on Linux
- Move macOS-specific configs (karabiner, aerospace) to darwin module
- Make zen-browser darwinDefaultsId conditional
- Add platform-specific apps (darwin-switch on macOS, home-switch on Linux)
- Update agent-browser pnpm deps hash
- Add comprehensive tmux config with plugins and catppuccin theme

- Prefix: Ctrl+b (classic default)
- Plugins: sensible, yank, pain-control, vim-tmux-navigator,
  resurrect, continuum, catppuccin
- Catppuccin mocha theme with rounded status style
- Vi-style pane navigation (hjkl)
- Alt+arrow for pane switching, Shift+arrow for windows
- Alt+1-9 for fast window switching
- Split panes with | and - in current directory
- Auto session save/restore with continuum
- True color support for modern terminals including ghostty
- Status bar at top with directory and session info
- Update tmux split keybindings: | for vertical, " for horizontal

- | splits side-by-side (visual: vertical line)
- " splits stacked above/below (visual: horizontal lines)
- Add Linux dev tools: docker CLI, build tools, debugging, libs

- Docker CLI, buildx, credential-helpers
- Build tools: ccache, bear, bison, flex, gettext, gnupatch
- Debugging: gdb, valgrind, perf-tools
- System monitoring: sysstat, iotop, nethogs
- Dev libraries: ncurses, bzip2, xz, libxml2, libyaml, expat (with headers)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
- Update Node to 24, add fnm, improve tmux for Ghostty

- Node.js 20 → 24.13.0 (latest)
- Add fnm (fast node manager) with shell integration
- tmux: Add synchronized output (mode 2026) to reduce flickering
- tmux: Extended keys support for Ghostty
- tmux: OSC 52 clipboard and cursor style support

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
- Add lspmux LSP multiplexer and cronjobs for both platforms

- Add lspmux package for sharing LSP instances between editors
- Add lspmux launchd service on macOS (runs at login)
- Add lspmux systemd user service on Linux
- Add cronjobs module for Linux (systemd timers)
- Add trackpad tap-to-click and three-finger drag settings
- Add Stylix theming and zsh/Starship Tokyo Night colors

- Replace Powerlevel10k with Starship prompt (Stylix-managed)
- Add Tokyo Night colors for zsh-syntax-highlighting
- Configure Starship module colors (aws, cmd_duration, git, etc.)
- Fix Homebrew cleanup to preserve dependencies
- Remove hardcoded themes from lazygit/delta (Stylix manages)
- Add Arc browser data extraction scripts for Zen migration

### Miscellaneous Tasks

- Remove Atuin
- Remove nvim-monitor, update configs and fix deprecations

- Remove nvim-monitor plugin
- Update Ghostty config with Tokyo Night theme and vim keybindings
- Fix SSH enableDefaultConfig deprecation warning
- Fix helm package (use kubernetes-helm)
- Fix sessionVariables conditional (use lib.optionalAttrs)
- Remove deprecated darwin.apple_sdk references
- Optimize sops secrets loading with caching
- Add VLC to homebrew casks
- Refactor packages.nix to use inherit and consolidate home attrs

### Other

- Initial nix-darwin flake with home-manager
- Manage full Homebrew package set
- Stop managing Node.js via Nix
- Prefer Homebrew for toolchains and disable auto upgrades
- Fold tool auto-updates into nix-sync job
- Auto-backup conflicting /etc files on switch
- Stop nix-darwin from managing /etc shell rc
- Auto-backup /etc/shells for nix-darwin
- Make Homebrew activation idempotent
- Backup existing dotfiles on first HM activation
- Restore shell PATH and zsh aliases
- Tighten defaults, caches, and job safety
- Vendor LazyVim config and add formatters
- Vendor OpenCode skills and manage ~/.opencode
- Track OpenCode plugin manifests
- Track OpenCode skill tool manifests
- Write OpenCode config to XDG path
- Manage OpenCode user commands
- Install wrapper apps via nix-darwin
- Vendor additional app configs
- Make bat output minimal
- Manage Rust CLI tools via Nix
- Vendor AeroSpace and Ghostty theme
- Vendor gh-dash and marimo configs
- Vendor lazygit and ueberzugpp configs
- Vendor lazycommit templates
- Resolve lazygit config conflict
- Avoid hardcoded home paths in app configs
- Manage commit_ai helper via Home Manager
- Use sops secret path for shell env
- Make darwin-switch app auto-detect flake path
- Do not override existing OPENAI_API_KEY
- Moremore
- Moremore
- More
- More
- Enable allowUnfree for darwin config and fix lint warnings

- Add nixpkgs.config.allowUnfree = true to darwin config for terraform etc.
- Use inherit pattern for isDarwin/isLinux in packages.nix and linux.nix
- Remove unused config parameter from linux.nix
- Clean up activation-tools.nix (remove unused profile fix)
- Moremore
- More
- More
- Configure nvim and opencode to use lspmux for rust-analyzer
- Consolidate Rust toolchain to nix, remove homebrew duplicates

- Remove CARGO_HOME from sessionVariables to prevent rust-analyzer from
  finding rustup proxies
- Remove ~/.cargo/bin from sessionPath - use nix rust exclusively
- Update lspmux config: fix TCP socket format, filter environment to
  exclude CARGO_HOME/RUSTUP_HOME
- Fix lspmux config path for macOS (~/Library/Application Support/)
- Update launchd PATH to prioritize nix profile over homebrew
- Configure rustaceanvim to use nix rust-analyzer and set proper env
- Remove 300+ duplicate brews that nix already provides
- Add explicit path to nix rust-analyzer in opencode config

This prevents conflicts between nix rust toolchain and rustup proxies,
especially for projects using nightly toolchains that don't bundle
rust-analyzer.
- Configure Claude Code to use lspmux for rust-analyzer

Add LSP server configuration to share rust-analyzer instance between
editors via lspmux. Uses nix-provided rust-analyzer path.
- Improve Home Manager setup using proper modules

Based on Home Manager manual review, migrate from packages to modules:

programs.nix:
- Add programs.fd with ignores configuration
- Add programs.ripgrep with smart-case and hidden file support
- Add programs.jq, programs.less, programs.man
- Add programs.htop and programs.btop with themes
- Add programs.atuin for better shell history (local-only)
- Add programs.yazi file manager with keymaps
- Add programs.k9s for Kubernetes with UI settings
- Add programs.tealdeer with auto-update
- Enable fish integration for zoxide, fzf, eza

terminal.nix:
- Migrate from xdg.configFile to programs.ghostty module
- Enable shell integrations (zsh, fish, bash)
- Use settings attribute for cleaner configuration

shell.nix:
- Remove .cargo/bin from fish PATH (nix rust only)

packages.nix:
- Remove packages now managed by modules:
  btop, htop, jq, ripgrep, fd, bat, eza, yazi, k9s,
  lazygit, gh, delta, tmux, starship, direnv, git
- Add comments noting which tools are module-managed

This follows Home Manager best practices: modules provide better
integration, shell completions, and declarative configuration vs
raw packages.
- More

### Performance

- Optimize packages: save 1.1GB, fix pre-commit regex

## Size Optimizations (-1.1 GiB closure)
- wireshark → wireshark-cli (removes Qt, -1.3GB)
- Remove nixd (keeps nil, -600MB LLVM dep)
- Remove terraform (keep opentofu only)
- Remove cloc, scc (keep tokei)
- Remove httpie, curlie (keep xh)

## Fixes
- Fix pre-commit prettier regex (*.nix → .*\.nix$)
- Add nix-direnv package

## Stats
- Closure: 11.6 GiB → 10.5 GiB
- Paths: 1281 → 1201 (-80)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

### Refactor

- Refactor flake with shared user/host args
- Refactor flake and tooling for reproducibility

Switch to flake-parts, remove upstream deprecations, and prefer Nix-pinned Node/Python while installing Rust CLIs via cargo-binstall.
- Refactor to pure nix: rust-overlay, remove apt scripts

- Add rust-overlay for declarative Rust toolchain management
- Use stable Rust with rust-src, rust-analyzer, clippy, rustfmt
- Add WASM targets (wasm32-unknown-unknown, wasm32-wasip1)
- Include all cargo tools from nixpkgs (no more cargo-binstall)
- Add comprehensive dev packages: Go, Node, Python, Java, Zig, Lua
- Add build tools and dev libraries (openssl, zlib, etc.)
- Set up proper environment variables for Rust builds
- Remove linux.nix apt script - pure nix approach
- Platform-specific packages via lib.optionals
- Refactor nix config: consolidate modules, add tools, fix linting

## Module Consolidation (44 → 30 files)
- Merge 6 zsh submodules into single zsh.nix
- Merge 5 git modules into single git.nix
- Merge bash.nix and fish.nix into shell.nix
- Centralize Ghostty terminal fix (was duplicated 3x)

## New Nix Tools (from awesome-nix)
- nvd: compare generations and see package changes
- nix-du: visualize store disk usage
- manix: search nix documentation
- nix-init: generate packages from URLs
- nurl: generate fetcher calls from URLs
- nixd: advanced Nix LSP (alongside nil)
- nix-melt: explore flake inputs

## Flake Improvements
- Add git-hooks.nix for native pre-commit hooks
- Add treefmt-nix for unified formatting
- New checks: pre-commit, formatting
- DevShell auto-installs git hooks

## Code Quality
- Fix all statix warnings (empty patterns → _)
- Fix all deadnix warnings (unused params)
- Standardize module signatures with comments

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

---
Generated with [git-cliff](https://git-cliff.org)
