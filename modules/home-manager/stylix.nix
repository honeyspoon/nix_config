# Stylix - system-wide theming
# https://nix-community.github.io/stylix/
{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  stylix = {
    enable = true;

    # Disable version mismatch warning (expected with different release cycles)
    enableReleaseChecks = false;

    # Use tokyo-night color scheme (matches your existing preferences)
    # Available schemes: https://github.com/tinted-theming/schemes
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    # Dark theme polarity
    polarity = "dark";

    # Wallpaper (required by stylix)
    # Using a solid color wallpaper generated from the theme
    image = pkgs.runCommand "tokyo-night-wallpaper.png" {
      nativeBuildInputs = [pkgs.imagemagick];
    } ''
      magick -size 1920x1080 xc:'#1a1b26' $out
    '';

    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        desktop = 12;
        applications = 12;
        terminal = 14;
        popups = 12;
      };
    };

    # Cursor theme
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # Application-specific targets
    # Disable targets for apps we configure manually or that don't work well
    targets = {
      # Home-manager targets
      bat.enable = true;
      btop.enable = true;
      fzf.enable = true;
      ghostty.enable = false; # We configure ghostty manually with tokyonight theme (package=null breaks systemd)
      kitty.enable = true;
      lazygit.enable = true;
      tmux.enable = false; # We have custom catppuccin config
      yazi.enable = true;
      vim.enable = true;

      # Zen browser theming
      zen-browser = {
        enable = true;
        profileNames = ["default"];
      };

      # Only available on Linux/NixOS
      # gnome.enable = lib.mkIf (!isDarwin) true;
      # gtk.enable = lib.mkIf (!isDarwin) true;
    };
  };
}
