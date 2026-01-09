{config, ...}: {
  home = {
    username = "abder";
    homeDirectory = "/Users/abder";
    stateVersion = "24.11";

    # Ensure user-installed binaries are on PATH for all shells.
    sessionPath = [
      "${config.home.homeDirectory}/.opencode/bin"
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
