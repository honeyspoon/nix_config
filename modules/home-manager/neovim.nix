{
  config,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home = {
    # Sanity check: LazyVim expects a few CLI tools. We don’t install them here
    # (you prefer Homebrew/NVM), but warn loudly if they’re missing.
    activation.checkNeovimDeps = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Home Manager activations run with a minimal PATH, so check common
      # locations (Homebrew + Nix) to avoid false positives.
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/run/current-system/sw/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

      have() {
        command -v "$1" >/dev/null 2>&1 && return 0
        [ -x "/opt/homebrew/bin/$1" ] && return 0
        [ -x "/usr/local/bin/$1" ] && return 0
        [ -x "/run/current-system/sw/bin/$1" ] && return 0
        [ -x "$HOME/.nix-profile/bin/$1" ] && return 0
        return 1
      }

      missing=""

      for cmd in rg fd fzf git; do
        have "$cmd" || missing="$missing $cmd"
      done

      # Optional but commonly required by plugins.
      for cmd in node python3; do
        have "$cmd" || missing="$missing $cmd"
      done

      if [ -n "$missing" ]; then
        msg="Neovim deps missing:$missing"
        printf '%s\n' "$msg" >&2
        if command -v /usr/bin/osascript >/dev/null 2>&1; then
          /usr/bin/osascript -e "display notification \"$msg\" with title \"Home Manager\""
        fi
      fi
    '';

    sessionVariables = {
      # Ensure the config is on the canonical path used by most tooling.
      NVIM_APPNAME = "nvim";

      # Optional: point tooling at the repo path for easier discovery.
      NVIM_CONFIG_HOME = "${config.home.homeDirectory}/nix-config/config/nvim";
    };
  };

  # Keep the whole Neovim/LazyVim config in this nix-config repo.
  # Home Manager will symlink it into ~/.config/nvim.
  xdg.configFile."nvim" = {
    source = ../../config/nvim;
    recursive = true;
  };
}
