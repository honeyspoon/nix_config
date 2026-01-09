_: {
  programs.fish = {
    enable = true;
    shellInit = ''
      # LM Studio CLI
      set -gx PATH $PATH /Users/abder/.lmstudio/bin
    '';
  };
}
