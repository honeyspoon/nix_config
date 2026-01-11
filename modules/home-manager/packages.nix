{
  lib,
  pkgs,
  ...
}: {
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

    # Languages / runtimes
    nodejs_20
    python3
    postgresql_17
    uv

    # Rust / Cargo CLI tools (installed via cargo-binstall)
    cargo-binstall

    # Development
    claude-code
    pre-commit
    shellcheck
  ];

  home.activation.cargoBinstallRustTools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v cargo >/dev/null 2>&1; then
      exit 0
    fi

    if ! command -v cargo-binstall >/dev/null 2>&1; then
      exit 0
    fi

    # Ensure binstall-installed binaries are reachable.
    export PATH="/run/current-system/sw/bin:$HOME/.cargo/bin:$PATH"

    export BINSTALL_DISABLE_TELEMETRY=1

    missing=()

    need() {
      crate="$1"
      bin="$2"

      if ! command -v "$bin" >/dev/null 2>&1; then
        missing+=("$crate")
      fi
    }

    need bacon bacon

    need cargo-audit cargo-audit
    need cargo-bloat cargo-bloat
    need cargo-deny cargo-deny
    need cargo-edit cargo-add
    need cargo-flamegraph cargo-flamegraph
    need cargo-generate cargo-generate
    need cargo-leptos cargo-leptos
    need cargo-lambda cargo-lambda
    need cargo-machete cargo-machete
    need cargo-make cargo-make
    need cargo-modules cargo-modules
    need cargo-sort cargo-sort
    need cargo-tauri cargo-tauri
    need cargo-udeps cargo-udeps
    need cargo-watch cargo-watch
    need cargo-zigbuild cargo-zigbuild
    need cargo-llvm-cov cargo-llvm-cov

    need evcxr evcxr
    need hurl hurl
    need mdcat mdcat
    need oha oha
    need rust-cbindgen cbindgen
    need rust-script rust-script
    need sqlx-cli sqlx
    need tokei tokei
    need tokio-console tokio-console
    need tree-sitter tree-sitter
    need trunk trunk
    need viu viu
    need wasm-pack wasm-pack
    need xan xan

    if [ "''${#missing[@]}" -gt 0 ]; then
      printf 'Installing %s rust tools via cargo-binstall...\n' "''${#missing[@]}" >&2

      cargo binstall \
        --no-confirm \
        --disable-strategies compile \
        --continue-on-failure \
        "''${missing[@]}" || true
    fi
  '';
}
