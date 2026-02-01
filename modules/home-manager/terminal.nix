# Ghostty terminal emulator configuration
# Uses programs.ghostty module instead of manual xdg.configFile
{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  programs.ghostty = {
    enable = true;
    # Package is installed via homebrew cask on macOS, use nixpkgs on Linux
    package = lib.mkIf (!isDarwin) pkgs.ghostty;

    # Enable shell integrations
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    # Note: installBatSyntax requires package to be non-null

    settings = {
      # Theme
      theme = "tokyonight";

      # Window settings
      window-save-state = "always";
      window-colorspace = "display-p3";

      # Font settings
      bold-is-bright = true;
      font-thicken = true;

      # Split opacity
      unfocused-split-opacity = 0.9;

      # Keybindings - vim-style split navigation
      keybind = [
        "performable:ctrl+h=goto_split:left"
        "performable:ctrl+j=goto_split:down"
        "performable:ctrl+k=goto_split:up"
        "performable:ctrl+l=goto_split:right"

        # Resize splits
        "performable:ctrl+shift+h=resize_split:left,10"
        "performable:ctrl+shift+j=resize_split:down,10"
        "performable:ctrl+shift+k=resize_split:up,10"
        "performable:ctrl+shift+l=resize_split:right,14"

        # tmux-like shortcuts
        "ctrl+a>z=toggle_split_zoom"
        "ctrl+a>shift+backslash=new_split:right"
        "ctrl+a>shift+apostrophe=new_split:down"
        "ctrl+a>ctrl+l=clear_screen"
      ];
    };
  };
}
