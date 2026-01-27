{
  pkgs,
  lib,
  ...
}: {
  programs = {
    home-manager.enable = true;

    nix-index = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        format = "$username$hostname$localip$shlvl$singularity$kubernetes$directory$vcsh$fossil_branch$fossil_metrics$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$pijul_channel$docker_context$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$gleam$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$scala$solidity$swift$terraform$typst$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$nats$direnv$env_var$crystal$custom$sudo$cmd_duration$line_break$jobs$battery$time$status$os$container$shell$character";

        # Keep prompt focused: no crate or rust version.
        package.disabled = true;
        rust.disabled = true;
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
        "--inline-info"
      ];
    };

    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        pager = "less -FR";
        style = "plain";
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      terminal = "screen-256color";

      extraConfig = ''
        # Split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf

        # Switch panes using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Enable RGB colour
        set-option -sa terminal-overrides ",xterm*:Tc"
        set-option -sa terminal-overrides ",ghostty:Tc"

        # Fix for ghostty terminal type on Linux (fallback if terminfo missing)
        set-option -g default-terminal "tmux-256color"
      '';
    };
  };

  home.activation.batCacheRebuild = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/bat"
    rm -rf "$cache_dir"

    if [ -x "${pkgs.bat}/bin/bat" ]; then
      "${pkgs.bat}/bin/bat" cache --build >/dev/null 2>&1 || true
    fi
  '';
}
