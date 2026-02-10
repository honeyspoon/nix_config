{
  pkgs,
  lib,
  ...
}: {
  programs = {
    home-manager.enable = true;

    # ══════════════════════════════════════════════════════════════════════════
    # SHELL INTEGRATIONS
    # ══════════════════════════════════════════════════════════════════════════
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

        # Tokyo Night colors (override Stylix base16 which has wrong mappings)
        directory.style = "bold #7aa2f7"; # blue
        git_branch.style = "bold #bb9af7"; # purple
        git_status.style = "bold #f7768e"; # red
        aws.style = "bold #e0af68"; # yellow (was cyan)
        cmd_duration.style = "bold #e0af68"; # yellow (was cyan)
        character = {
          success_symbol = "[❯](bold #9ece6a)"; # green
          error_symbol = "[❯](bold #f7768e)"; # red
        };
        nodejs.style = "bold #9ece6a"; # green
        python.style = "bold #e0af68"; # yellow
        rust.style = "bold #ff9e64"; # orange
        golang.style = "bold #7dcfff"; # cyan
        docker_context.style = "bold #7dcfff"; # cyan
        kubernetes.style = "bold #7aa2f7"; # blue
        terraform.style = "bold #bb9af7"; # purple
        nix_shell.style = "bold #7aa2f7"; # blue
        time.style = "bold #565f89"; # gray
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
        "--inline-info"
      ];
      # colors managed by Stylix
      # Use fd for file/directory completion
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    };

    # ══════════════════════════════════════════════════════════════════════════
    # MODERN CLI REPLACEMENTS (with configuration)
    # ══════════════════════════════════════════════════════════════════════════
    bat = {
      enable = true;
      config = {
        # theme is managed by Stylix
        pager = "less -FR";
        style = "plain";
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
    };

    # fd - find replacement (configured via module instead of just package)
    fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
        "node_modules/"
        "target/"
        ".direnv/"
      ];
    };

    # ripgrep - grep replacement
    ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
        "--hidden"
        "--glob=!.git/*"
        "--glob=!node_modules/*"
        "--glob=!target/*"
      ];
    };

    # jq - JSON processor
    jq.enable = true;

    # less - pager with better defaults
    less = {
      enable = true;
      # Vim-style horizontal scrolling
      config = ''
        #command
        h left-scroll
        l right-scroll
      '';
    };

    # htop - process viewer
    htop = {
      enable = true;
      settings = {
        show_program_path = false;
        highlight_base_name = true;
        tree_view = true;
      };
    };

    # btop - modern system monitor
    btop = {
      enable = true;
      settings = {
        # color_theme is managed by Stylix
        vim_keys = true;
        rounded_corners = true;
        update_ms = 1000;
      };
    };

    # ══════════════════════════════════════════════════════════════════════════
    # SHELL HISTORY (atuin - better than plain history)
    # ══════════════════════════════════════════════════════════════════════════
    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      flags = ["--disable-up-arrow"]; # Don't override up arrow
      settings = {
        auto_sync = false; # Local only
        search_mode = "fuzzy";
        filter_mode = "global";
        style = "compact";
        inline_height = 20;
        show_preview = true;
      };
    };

    # ══════════════════════════════════════════════════════════════════════════
    # FILE MANAGERS
    # ══════════════════════════════════════════════════════════════════════════
    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
      keymap = {
        manager.keymap = [
          {
            on = ["<Esc>"];
            run = "escape";
            desc = "Exit visual mode, clear selected, or cancel search";
          }
          {
            on = ["q"];
            run = "quit";
            desc = "Exit the process";
          }
          {
            on = ["Q"];
            run = "quit --no-cwd-file";
            desc = "Exit without writing cwd file";
          }
        ];
      };
    };

    # ══════════════════════════════════════════════════════════════════════════
    # DEVOPS TOOLS
    # ══════════════════════════════════════════════════════════════════════════
    # k9s - Kubernetes TUI
    k9s = {
      enable = true;
      settings = {
        k9s = {
          liveViewAutoRefresh = true;
          refreshRate = 2;
          ui = {
            enableMouse = true;
            headless = false;
            logoless = true;
            crumbsless = false;
            noIcons = false;
            skin = "dracula";
          };
        };
      };
    };

    # ══════════════════════════════════════════════════════════════════════════
    # DOCUMENTATION
    # ══════════════════════════════════════════════════════════════════════════
    # tealdeer - fast tldr client
    tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = false;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 720; # 30 days
        };
      };
    };

    # man page configuration
    man = {
      enable = true;
      generateCaches = true;
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-b";
      terminal = "tmux-256color";
      sensibleOnTop = true;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        pain-control
        vim-tmux-navigator
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }
        {
          plugin = catppuccin;
          extraConfig = ''
            # Catppuccin theme settings
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_status_style "rounded"

            # Window format
            set -g @catppuccin_window_number_position "left"
            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"
            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"

            # Status bar
            set -g @catppuccin_status_background "default"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"

            # Status modules
            set -g @catppuccin_status_modules_right "directory session"
            set -g @catppuccin_directory_text "#{pane_current_path}"
          '';
        }
      ];

      extraConfig = ''
        # ══════════════════════════════════════════════════════════════════
        # GHOSTTY / TERMINAL COMPATIBILITY
        # ══════════════════════════════════════════════════════════════════
        # True color support
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -ag terminal-overrides ",*256col*:RGB"
        set -ag terminal-overrides ",ghostty:RGB"
        set -ag terminal-overrides ",xterm-ghostty:RGB"

        # Synchronized output (mode 2026) - reduces flickering in fast terminals like Ghostty
        set -ag terminal-overrides ",xterm-ghostty:Sync"
        set -ag terminal-overrides ",ghostty:Sync"
        set -ag terminal-overrides ",xterm-256color:Sync"

        # Extended keys support for Ghostty (better keybinding support)
        set -s extended-keys on
        set -s extended-keys-format csi-u
        set -as terminal-features 'xterm-ghostty:extkeys'
        set -as terminal-features 'ghostty:extkeys'

        # Clipboard integration (OSC 52)
        set -s set-clipboard on
        set -ag terminal-overrides ",xterm-ghostty:Ms=\\E]52;c;%p2%s\\7"
        set -ag terminal-overrides ",ghostty:Ms=\\E]52;c;%p2%s\\7"

        # Cursor style support
        set -ag terminal-overrides ",xterm-ghostty:Cs=\\E]12;%p1%s\\7"
        set -ag terminal-overrides ",ghostty:Cs=\\E]12;%p1%s\\7"

        # ══════════════════════════════════════════════════════════════════
        # PERFORMANCE / STABILITY
        # ══════════════════════════════════════════════════════════════════
        # Increase message buffer
        set -g message-limit 100

        # Split panes: | for vertical (side-by-side), " for horizontal (stacked)
        bind | split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        unbind %

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Vim-style pane selection
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Resize panes with Ctrl+hjkl
        bind -r C-h resize-pane -L 5
        bind -r C-j resize-pane -D 5
        bind -r C-k resize-pane -U 5
        bind -r C-l resize-pane -R 5

        # Alt-arrow to switch panes without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Shift-arrow to switch windows without prefix
        bind -n S-Left previous-window
        bind -n S-Right next-window

        # Easy window reordering
        bind -r "<" swap-window -d -t -1
        bind -r ">" swap-window -d -t +1

        # Don't rename windows automatically
        set -g allow-rename off

        # Renumber windows when one is closed
        set -g renumber-windows on

        # Set title
        set -g set-titles on
        set -g set-titles-string "#T"

        # Activity monitoring
        set -g monitor-activity on
        set -g visual-activity off

        # Vi copy mode improvements
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Fast window switching
        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        # Focus events for vim
        set -g focus-events on

        # Longer status messages
        set -g display-time 2000
        set -g display-panes-time 2000

        # Status bar position
        set -g status-position top
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
