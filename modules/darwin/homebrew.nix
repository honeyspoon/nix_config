_: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask-fonts"
      "homebrew/services"
      "nikitabobko/tap"
    ];

    brews = [
      "powerlevel10k"
      "antigen"
    ];

    casks = [
      "firefox"
      "google-chrome"

      "visual-studio-code"
      "zed"

      "ghostty"
      "iterm2"

      "nikitabobko/tap/aerospace"

      "discord"
      "slack"

      "raycast"
      "karabiner-elements"
      "1password"

      "dbeaver-community"

      "orbstack"
    ];

    masApps = {
      # "Xcode" = 497799835;
    };
  };
}
