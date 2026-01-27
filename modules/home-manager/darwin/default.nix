# macOS-specific home-manager modules
# Uses lib.mkIf so this module can be imported on all platforms
{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  # Only apply these configs on macOS
  xdg.configFile = lib.mkIf isDarwin {
    "karabiner/karabiner.json".source = ../../../config/karabiner/karabiner.json;

    "karabiner/assets/complex_modifications" = {
      source = ../../../config/karabiner/assets/complex_modifications;
      recursive = true;
    };

    "aerospace/aerospace.toml".source = ../../../config/aerospace/aerospace.toml;
  };
}
