{config, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Pin legacy location to silence deprecation warnings.
    dotDir = config.home.homeDirectory;
  };
}
