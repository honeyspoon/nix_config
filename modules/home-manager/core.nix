{
  config,
  pkgs,
  user,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = "24.11";

    # Ensure user-installed binaries are on PATH for all shells.
    sessionPath =
      [
        "${config.home.profileDirectory}/bin"
      ]
      ++ (
        # macOS/NixOS system profile path
        if isDarwin
        then ["/run/current-system/sw/bin"]
        else []
      );

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
  };

  xdg.enable = true;
}
