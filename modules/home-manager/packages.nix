{
  lib,
  pkgs,
  config,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = with pkgs;
    [
      # === CLI Tools ===
      btop
      htop
      tree
      wget
      curl
      jq
      yq-go
      watch
      parallel
      expect

      # === Network Tools ===
      nmap
      wireshark
      mtr

      # === Archive Tools ===
      unzip
      zip
      gnutar
      p7zip

      # === Text Processing ===
      gnused
      gawk
      ripgrep
      sd # sed alternative

      # === Modern CLI Replacements ===
      dust # du alternative
      duf # df alternative
      procs # ps alternative
      fd # find alternative
      bat # cat alternative
      eza # ls alternative
      delta # diff alternative
      hyperfine # benchmarking
      tokei # code stats

      # === File Management ===
      xplr # file explorer
      yazi # terminal file manager

      # === Git Tools ===
      git
      git-lfs
      lazygit
      gh # GitHub CLI

      # === Languages / Runtimes ===
      # Rust
      rustup

      # Go
      go

      # Node.js
      nodejs_20
      bun
      deno

      # Python
      python3
      python3Packages.pip
      python3Packages.datadog
      uv
      pipx

      # Java
      jdk21

      # Zig
      zig

      # === Databases ===
      postgresql_17
      sqlite

      # === Build Tools ===
      cmake
      gnumake
      ninja
      pkg-config
      autoconf
      automake
      libtool

      # === DevOps / Cloud ===
      awscli2
      terraform
      opentofu
      pulumi
      kubectl
      k9s
      dive # docker image explorer
      lazydocker

      # === API / HTTP Tools ===
      httpie
      xh # httpie alternative
      grpcurl
      websocat

      # === Data Tools ===
      jless # json viewer
      fx # json processor
      csvkit

      # === Security Tools ===
      trivy
      hadolint
      shellcheck
      mkcert

      # === Misc Dev Tools ===
      just # command runner
      direnv
      entr # file watcher
      watchexec
      act # GitHub Actions locally
      scc # code counter

      # === Terminal Tools ===
      tmux
      zellij
      starship
      fastfetch

      # === Nix Tools ===
      comma
      nix-tree
      nixfmt-rfc-style
      statix
      deadnix

      # === Rust / Cargo CLI tools (installed via cargo-binstall) ===
      cargo-binstall

      # === AI / Development ===
      claude-code
      agent-browser
      ollama

      # === Pre-commit ===
      pre-commit
    ]
    ++ lib.optionals isLinux [
      # Linux-specific packages
      gcc
      glibc
      binutils
      patchelf

      # Linux system tools
      strace
      ltrace
      lsof
      file
    ]
    ++ lib.optionals isDarwin [
      # macOS-specific packages (most are via homebrew)
      coreutils
      findutils
    ];

  home.activation.cargoBinstallRustTools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v cargo >/dev/null 2>&1; then
      exit 0
    fi

    if ! command -v cargo-binstall >/dev/null 2>&1; then
      exit 0
    fi

    # Ensure binstall-installed binaries are reachable.
    export PATH="${config.home.profileDirectory}/bin:$HOME/.cargo/bin:$PATH"

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
