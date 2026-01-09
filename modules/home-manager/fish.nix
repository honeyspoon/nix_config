{config, ...}: {
  programs.fish = {
    enable = true;
    shellInit = ''
      # LM Studio CLI
      set -gx PATH $PATH ${config.home.homeDirectory}/.lmstudio/bin
    '';
  };
}
