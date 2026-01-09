{pkgs, ...}: {
  home.packages = with pkgs; [
    # Additional CLI tools
    btop
    htop
    tree
    wget
    curl
    jq
    yq-go

    # Network tools
    nmap
    wireshark

    # Archive tools
    unzip
    zip
    gnutar

    # Text processing
    gnused
    gawk

    # Modern alternatives
    dust
    duf
    procs

    # Development
    pre-commit
    shellcheck

    # Rust tools
    cargo-watch
    cargo-edit

    # Python tools
    python312Packages.pip
    python312Packages.ipython
  ];
}
