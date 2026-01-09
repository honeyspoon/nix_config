{pkgs, ...}: {
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    neovim
    git
    curl
    wget

    # Modern CLI replacements
    eza # ls replacement
    bat # cat replacement
    fd # find replacement
    ripgrep # grep replacement
    delta # git diff viewer

    # Development tools
    gh # GitHub CLI
    lazygit
    direnv
    jq

    # Terminal multiplexing
    tmux

    # Shell tools
    fzf
    zoxide
    atuin
    starship

    # Language toolchains
    rustup
    nodejs_22
    python312

    # Build tools
    cmake
    gnumake
    pkg-config

    # Database tools
    postgresql_17

    # Container tools
    docker

    # Nix tools
    nil # Nix LSP
    alejandra
    statix
    deadnix
  ];
}
