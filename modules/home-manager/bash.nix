{config, ...}: {
  programs.bash = {
    enable = true;
    inherit (config.programs.zsh) shellAliases;
  };
}
