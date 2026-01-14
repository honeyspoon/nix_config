{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
      }
    ];

    # dotDir must be relative to $HOME, not an absolute path.
    # Empty string means use $HOME directly (default behavior).
    dotDir = ".config/zsh";
  };
}
