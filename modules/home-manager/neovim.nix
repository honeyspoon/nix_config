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
      missing=""

      for cmd in rg fd fzf git; do
        command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
      done

      # Optional but commonly required by plugins.
      for cmd in node python3; do
        command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
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
