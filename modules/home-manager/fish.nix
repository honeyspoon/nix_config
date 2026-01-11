{config, ...}: {
  programs.fish = {
    enable = true;
    shellInit = ''
      # LM Studio CLI
      fish_add_path -g ${config.home.homeDirectory}/.lmstudio/bin

      # cargo-binstall installs into ~/.cargo/bin
      fish_add_path -g ${config.home.homeDirectory}/.cargo/bin
    '';
  };
}
