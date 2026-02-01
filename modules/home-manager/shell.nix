# Shell configuration (zsh, bash, fish)
# Ghostty terminal compatibility is handled centrally here
{config, ...}: let
  # Shared Ghostty terminal fix for all shells
  # Fixes TERM when terminfo is missing on Linux
  ghosttyTermFix = ''
    if [[ "$TERM" == ghostty* || "$TERM" == xterm-ghostty* ]] && ! infocmp "$TERM" &>/dev/null 2>&1; then
      export TERM=xterm-256color
    fi
  '';

  # Fish version of the fix (different syntax)
  ghosttyTermFixFish = ''
    if string match -q 'ghostty*' "$TERM"; or string match -q 'xterm-ghostty*' "$TERM"
      if not infocmp "$TERM" &>/dev/null
        set -gx TERM xterm-256color
      end
    end
  '';
in {
  imports = [
    ./zsh.nix
  ];

  # ══════════════════════════════════════════════════════════════════════════
  # BASH
  # ══════════════════════════════════════════════════════════════════════════
  programs.bash = {
    enable = true;
    inherit (config.programs.zsh) shellAliases;
    initExtra = ghosttyTermFix;
  };

  # ══════════════════════════════════════════════════════════════════════════
  # FISH
  # ══════════════════════════════════════════════════════════════════════════
  programs.fish = {
    enable = true;
    shellInit = ''
      ${ghosttyTermFixFish}

      # LM Studio CLI
      fish_add_path -g ${config.home.homeDirectory}/.lmstudio/bin

      # NOTE: .cargo/bin is NOT added - we use nix rust toolchain exclusively
      # Cargo-installed tools (non-rustup) can still be accessed via full path
    '';
  };
}
