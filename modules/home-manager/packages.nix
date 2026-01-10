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

    # Rust / Cargo CLI tools (replaces most `cargo install` bins)
    bacon
    cargo-audit
    cargo-binstall
    cargo-bloat
    cargo-deny
    cargo-edit
    cargo-flamegraph
    cargo-generate
    cargo-leptos
    cargo-lambda
    cargo-machete
    cargo-make
    cargo-modules
    cargo-sort
    cargo-tauri
    cargo-udeps
    cargo-watch
    cargo-zigbuild
    cargo-llvm-cov
    evcxr
    hurl
    mdcat
    oha
    rust-cbindgen
    rust-script
    sqlx-cli
    tokei
    tokio-console
    tree-sitter
    trunk
    uv
    viu
    wasm-pack
    xan

    # Development
    pre-commit
    shellcheck
  ];
}
