# Zsh shell configuration
# Consolidated from multiple submodules for maintainability
{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#565f89"; # Tokyo Night comment color for suggestions
    };
    syntaxHighlighting = {
      enable = true;
      # Tokyo Night color scheme for zsh-syntax-highlighting
      styles = {
        # Commands and builtins
        command = "fg=#7aa2f7"; # blue
        builtin = "fg=#7aa2f7"; # blue
        alias = "fg=#7aa2f7"; # blue
        function = "fg=#7aa2f7"; # blue

        # Arguments and options
        single-hyphen-option = "fg=#bb9af7"; # purple
        double-hyphen-option = "fg=#bb9af7"; # purple
        arg0 = "fg=#7aa2f7"; # blue

        # Paths and files
        path = "fg=#73daca,underline"; # teal
        path_pathseparator = "fg=#f7768e"; # red
        autodirectory = "fg=#73daca,underline"; # teal

        # Strings and quotes
        single-quoted-argument = "fg=#9ece6a"; # green
        double-quoted-argument = "fg=#9ece6a"; # green
        dollar-quoted-argument = "fg=#9ece6a"; # green
        back-quoted-argument = "fg=#bb9af7"; # purple
        back-quoted-argument-delimiter = "fg=#bb9af7"; # purple

        # Variables and substitutions
        dollar-double-quoted-argument = "fg=#e0af68"; # yellow
        back-double-quoted-argument = "fg=#e0af68"; # yellow
        assign = "fg=#c0caf5"; # foreground
        named-fd = "fg=#73daca"; # teal
        numeric-fd = "fg=#73daca"; # teal

        # Comments
        comment = "fg=#565f89"; # comment gray

        # Redirections and operators
        redirection = "fg=#89ddff"; # cyan
        commandseparator = "fg=#bb9af7"; # purple
        reserved-word = "fg=#bb9af7"; # purple

        # Globbing
        globbing = "fg=#ff9e64"; # orange
        history-expansion = "fg=#bb9af7"; # purple

        # Errors
        unknown-token = "fg=#f7768e"; # red
        precommand = "fg=#73daca,italic"; # teal italic
        suffix-alias = "fg=#73daca,underline"; # teal underline
        global-alias = "fg=#e0af68"; # yellow

        # Default
        default = "fg=#c0caf5"; # foreground
      };
    };

    # ══════════════════════════════════════════════════════════════════════
    # PLUGINS
    # ══════════════════════════════════════════════════════════════════════
    # Note: Starship prompt is used instead of Powerlevel10k (managed by Stylix)
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
      }
    ];

    # ══════════════════════════════════════════════════════════════════════
    # HISTORY
    # ══════════════════════════════════════════════════════════════════════
    history = {
      # Huge history files can get slow/fragile; Atuin already handles deep history.
      size = 1000000;
      save = 1000000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = false;
      extended = true;
      append = true;
      expireDuplicatesFirst = true;
    };

    # ══════════════════════════════════════════════════════════════════════
    # ALIASES
    # ══════════════════════════════════════════════════════════════════════
    shellAliases = {
      # Git
      g = "git";
      lg = "lazygit";

      # Python
      python = "python3";
      pip = "pip3";

      # Modern CLI replacements
      ls = "eza";
      bat = "${pkgs.bat}/bin/bat";
      cat = "${pkgs.bat}/bin/bat";

      # Utilities
      clast = "fc -s :0 | { pbcopy || wl-copy || xclip -selection clipboard; }";
      wt = "cd \"$(git worktree list | fzf | awk '{print $1}')\"";
      awscli = "awscliv2";

      # Editor
      vi = "nvim";
      vim = "nvim";

      # Nix commands
      nix-rebuild = "nix run ~/nix-config#darwin-switch";
      nix-update = "cd ~/nix-config && nix flake update && nix run .#darwin-switch";
      nix-clean = "nix-collect-garbage -d && nix-store --optimize";
      nix-generations = "nvd list"; # list generations with package changes
      nix-diff-gen = "nvd diff"; # diff two generations
      ns = "nix search nixpkgs";
      nloc = "nix-locate";
      nf = "nix flake show --all-systems";
      nb = "nom build";
      ndiff = "nix-diff";
      ntree = "nix-tree";
      ndu = "nix-du -s=500MB | dot -Tsvg > /tmp/nix-store.svg && open /tmp/nix-store.svg"; # visualize store
      nmelt = "nix-melt";
      ndoc = "manix"; # search nix documentation

      # Rust clippy presets
      clippy-mantis = "cargo clippy --all-features -- -D warnings -W clippy::pedantic -W clippy::nursery -W clippy::cargo -A clippy::module_name_repetitions -A clippy::missing_errors_doc -A clippy::missing_panics_doc -A clippy::must_use_candidate -A clippy::return_self_not_must_use -A clippy::cargo_common_metadata -A clippy::multiple_crate_versions -A clippy::too_many_lines -A clippy::large_stack_arrays -A clippy::large_futures -A clippy::derive_partial_eq_without_eq";
      clippy-mantis-fix = "cargo clippy --fix --allow-dirty --allow-staged --all-features -- -D warnings -W clippy::pedantic -W clippy::nursery -W clippy::cargo -A clippy::module_name_repetitions -A clippy::missing_errors_doc -A clippy::missing_panics_doc -A clippy::must_use_candidate -A clippy::return_self_not_must_use -A clippy::cargo_common_metadata -A clippy::multiple_crate_versions -A clippy::too_many_lines -A clippy::large_stack_arrays -A clippy::large_futures -A clippy::derive_partial_eq_without_eq";
    };

    # ══════════════════════════════════════════════════════════════════════
    # SESSION VARIABLES
    # ══════════════════════════════════════════════════════════════════════
    sessionVariables = {
      # Prompt managed by Starship
    };

    # ══════════════════════════════════════════════════════════════════════
    # INIT CONTENT
    # ══════════════════════════════════════════════════════════════════════
    initContent = lib.mkMerge [
      # Main init (runs first)
      ''
        # Increase file descriptor limit for Rust builds
        ulimit -n 10240

        # Ensure nix-darwin system profile is on PATH
        if [ -d /run/current-system/sw/bin ]; then
          case ":$PATH:" in
            *":/run/current-system/sw/bin:"*) ;;
            *) export PATH="/run/current-system/sw/bin:$PATH" ;;
          esac
        fi

        # Prefer OpenCode installed under ~/.opencode/bin (self-updating).
        if [ -d "$HOME/.opencode/bin" ]; then
          case ":$PATH:" in
            *":$HOME/.opencode/bin:"*) ;;
            *) export PATH="$HOME/.opencode/bin:$PATH" ;;
          esac
        fi

        # Ghostty TERM workaround: if terminfo is missing, fall back.
        if [[ "''${TERM:-}" == ghostty* || "''${TERM:-}" == xterm-ghostty* ]]; then
          if ! infocmp "$TERM" >/dev/null 2>&1; then
            export TERM="xterm-256color"
          fi
        fi

        # If you haven't successfully switched yet, `darwin-rebuild` won't exist.
        # Provide a tiny fallback that uses your flake apps.
        if ! command -v darwin-rebuild >/dev/null 2>&1; then
          darwin-rebuild() {
            case "''${1:-}" in
              build)
                nix run "$HOME/nix-config#darwin-build"
                ;;
              switch|*)
                nix run "$HOME/nix-config#darwin-switch"
                ;;
            esac
          }
        fi

        # Prompt is handled by Starship (configured via programs.starship)

        # Prefer Nix-provided runtimes (avoid brew/nvm/conda drift)
        export UV_PYTHON_PREFERENCE="only-system"

        # fzf keybindings/completions (Ctrl-T/Ctrl-R) for zsh.
        if command -v fzf >/dev/null 2>&1; then
          eval "$(fzf --zsh)"
        fi

        # zsh-vi-mode overrides keybindings after init, so we must use its hook.
        # Re-apply fzf bindings for vi keymaps.
        zvm_after_init() {
          bindkey "^R" fzf-history-widget
          bindkey -M viins "^R" fzf-history-widget
          bindkey -M vicmd "^R" fzf-history-widget

          bindkey "^T" fzf-file-widget
          bindkey -M viins "^T" fzf-file-widget
          bindkey -M vicmd "^T" fzf-file-widget
        }

        # Cargo binaries (append so Nix-provided tools win)
        if [ -d "$HOME/.cargo/bin" ]; then
          case ":$PATH:" in
            *":$HOME/.cargo/bin:"*) ;;
            *) export PATH="$PATH:$HOME/.cargo/bin" ;;
          esac
        fi

        # jenv (Java version manager)
        if command -v jenv &>/dev/null; then
          export PATH="$HOME/.jenv/bin:$PATH"
          eval "$(jenv init -)"
        fi

        # fnm (fast node manager) - use different Node versions per project
        if command -v fnm &>/dev/null; then
          eval "$(fnm env --use-on-cd)"
        fi

        # LM Studio CLI
        export PATH="$PATH:${config.home.homeDirectory}/.lmstudio/bin"

        # Solana CLI
        export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

        # Amp CLI
        export PATH="${config.home.homeDirectory}/.amp/bin:$PATH"

        # Local binaries (ocx, etc.)
        export PATH="$HOME/.local/bin:$PATH"

        # Clear screen on shell start
        clear
      ''

      # History options (runs after main init)
      (lib.mkAfter ''
        # Write each command to the history file immediately.
        setopt INC_APPEND_HISTORY
        setopt HIST_FCNTL_LOCK

        # Keep session-local history; don't import other sessions live.
        setopt NO_SHARE_HISTORY

        # Reduce noise in the history file.
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_SAVE_NO_DUPS
        setopt HIST_REDUCE_BLANKS
      '')
    ];
  };

  # ════════════════════════════════════════════════════════════════════════
  # ACTIVATION HOOKS
  # ════════════════════════════════════════════════════════════════════════
  # Ensure old compiled zshrc does not shadow Home Manager's ~/.zshrc.
  home.activation.removeZshrcZwc = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -e "$HOME/.zshrc.zwc" ] && [ ! -L "$HOME/.zshrc.zwc" ]; then
      rm -f "$HOME/.zshrc.zwc" "$HOME/.zshrc.zwc.old" 2>/dev/null || true
    fi
  '';
}
