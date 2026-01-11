{
  config,
  user,
  ...
}: {
  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = "24.11";

    # Ensure user-installed binaries are on PATH for all shells.
    sessionPath = [
      "/run/current-system/sw/bin"
      "${config.home.profileDirectory}/bin"
    ];

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
