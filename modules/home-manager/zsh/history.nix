{config, ...}: {
  programs.zsh.history = {
    size = 1000000000;
    save = 1000000000;
    path = "${config.home.homeDirectory}/.zsh_history";
    ignoreDups = true;
    share = true;
    extended = true;
  };
}
