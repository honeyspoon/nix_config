{config, ...}: {
  programs.fish = {
    enable = true;
    shellInit = ''
      # LM Studio CLI
      fish_add_path -g ${config.home.homeDirectory}/.lmstudio/bin

      # OpenCode CLI (installed via curl installer)
      fish_add_path -g ${config.home.homeDirectory}/.opencode/bin
    '';
  };
}
