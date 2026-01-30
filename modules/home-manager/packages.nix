{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin isLinux;

  # Rust toolchain from rust-overlay
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = ["rust-src" "rust-analyzer" "clippy" "rustfmt"];
    targets = ["wasm32-unknown-unknown" "wasm32-wasip1"];
  };
in {
  home = {
    packages = with pkgs;
      [
        # ══════════════════════════════════════════════════════════════════
        # RUST TOOLCHAIN (from rust-overlay)
        # ══════════════════════════════════════════════════════════════════
        rustToolchain

        # Cargo tools (from nixpkgs)
        cargo-audit
        cargo-bloat
        cargo-deny
        cargo-edit # cargo add/rm/upgrade
        cargo-expand
        cargo-flamegraph
        cargo-generate
        cargo-machete
        cargo-make
        cargo-modules
        cargo-nextest
        cargo-outdated
        cargo-release
        cargo-sort
        cargo-watch
        cargo-zigbuild

        # Rust utilities
        bacon # background rust checker
        sqlx-cli
        trunk # WASM web dev
        wasm-pack
        wasm-bindgen-cli
        leptosfmt

        # ══════════════════════════════════════════════════════════════════
        # OTHER LANGUAGES / RUNTIMES
        # ══════════════════════════════════════════════════════════════════
        # Go
        go
        gopls
        golangci-lint
        delve # debugger

        # Node.js / JavaScript
        nodejs_20
        bun
        deno
        nodePackages.pnpm
        nodePackages.typescript
        nodePackages.typescript-language-server

        # Python
        python3
        python3Packages.pip
        python3Packages.virtualenv
        uv
        ruff # linter/formatter
        pyright # type checker

        # Java
        jdk21
        maven
        gradle

        # Zig
        zig
        zls # language server

        # Lua (luajit only - lua conflicts with luajit)
        luajit
        luarocks

        # ══════════════════════════════════════════════════════════════════
        # BUILD TOOLS & DEVELOPMENT LIBRARIES
        # ══════════════════════════════════════════════════════════════════
        # Build essentials
        cmake
        gnumake
        ninja
        meson
        pkg-config
        autoconf
        automake
        libtool

        # Common development libraries
        openssl
        openssl.dev
        zlib
        zlib.dev
        libffi
        readline

        # ══════════════════════════════════════════════════════════════════
        # DATABASES
        # ══════════════════════════════════════════════════════════════════
        postgresql_17
        sqlite
        redis

        # ══════════════════════════════════════════════════════════════════
        # CLI TOOLS
        # ══════════════════════════════════════════════════════════════════
        btop
        htop
        tree
        wget
        curl
        jq
        yq-go
        watch
        parallel

        # ══════════════════════════════════════════════════════════════════
        # NETWORK TOOLS
        # ══════════════════════════════════════════════════════════════════
        nmap
        wireshark
        mtr
        bandwhich # bandwidth monitor
        dogdns # dns client

        # ══════════════════════════════════════════════════════════════════
        # ARCHIVE TOOLS
        # ══════════════════════════════════════════════════════════════════
        unzip
        zip
        gnutar
        p7zip
        zstd
        xz

        # ══════════════════════════════════════════════════════════════════
        # TEXT PROCESSING
        # ══════════════════════════════════════════════════════════════════
        gnused
        gawk
        ripgrep
        sd # sed alternative

        # ══════════════════════════════════════════════════════════════════
        # MODERN CLI REPLACEMENTS
        # ══════════════════════════════════════════════════════════════════
        dust # du alternative
        duf # df alternative
        procs # ps alternative
        fd # find alternative
        bat # cat alternative
        eza # ls alternative
        delta # diff alternative
        hyperfine # benchmarking
        tokei # code stats
        oha # http load tester

        # ══════════════════════════════════════════════════════════════════
        # FILE MANAGEMENT
        # ══════════════════════════════════════════════════════════════════
        xplr # file explorer
        yazi # terminal file manager
        broot # tree explorer

        # ══════════════════════════════════════════════════════════════════
        # GIT TOOLS
        # ══════════════════════════════════════════════════════════════════
        git
        git-lfs
        lazygit
        gh # GitHub CLI
        difftastic # structural diff
        git-absorb

        # ══════════════════════════════════════════════════════════════════
        # DEVOPS / CLOUD
        # ══════════════════════════════════════════════════════════════════
        awscli2
        terraform
        opentofu
        pulumi
        kubectl
        kubectx
        k9s
        kubernetes-helm
        dive # docker image explorer
        lazydocker
        docker-compose

        # ══════════════════════════════════════════════════════════════════
        # API / HTTP TOOLS
        # ══════════════════════════════════════════════════════════════════
        httpie
        xh # httpie alternative
        grpcurl
        websocat
        curlie # curl with httpie syntax

        # ══════════════════════════════════════════════════════════════════
        # DATA TOOLS
        # ══════════════════════════════════════════════════════════════════
        jless # json viewer
        fx # json processor
        dasel # json/yaml/toml query
        miller # csv/json processing

        # ══════════════════════════════════════════════════════════════════
        # SECURITY TOOLS
        # ══════════════════════════════════════════════════════════════════
        trivy
        hadolint
        shellcheck
        mkcert
        age # encryption
        sops

        # ══════════════════════════════════════════════════════════════════
        # MISC DEV TOOLS
        # ══════════════════════════════════════════════════════════════════
        just # command runner
        direnv
        entr # file watcher
        watchexec
        act # GitHub Actions locally
        scc # code counter
        cloc
        hexyl # hex viewer
        viu # image viewer in terminal

        # ══════════════════════════════════════════════════════════════════
        # TERMINAL TOOLS
        # ══════════════════════════════════════════════════════════════════
        tmux
        zellij
        starship
        fastfetch

        # ══════════════════════════════════════════════════════════════════
        # NIX TOOLS
        # ══════════════════════════════════════════════════════════════════
        comma # run programs without installing
        nix-tree
        nix-diff
        nixfmt-rfc-style
        statix
        deadnix
        cachix
        nix-prefetch-git
        nix-output-monitor # nom

        # ══════════════════════════════════════════════════════════════════
        # AI / DEVELOPMENT
        # ══════════════════════════════════════════════════════════════════
        claude-code
        agent-browser
        ollama

        # ══════════════════════════════════════════════════════════════════
        # CODE QUALITY
        # ══════════════════════════════════════════════════════════════════
        pre-commit
        treefmt
      ]
      ++ lib.optionals isLinux [
        # ════════════════════════════════════════════════════════════════
        # LINUX-SPECIFIC PACKAGES
        # ════════════════════════════════════════════════════════════════
        # Compilers and build tools (gcc only - clang conflicts)
        gcc
        binutils
        patchelf
        nix-ld # run unpatched binaries

        # System debugging
        strace
        ltrace
        lsof
        file

        # System libraries (headers for compilation)
        glibc
        glibc.dev
        libcap

        # Clipboard
        xclip
        xsel
        wl-clipboard
      ]
      ++ lib.optionals isDarwin [
        # ════════════════════════════════════════════════════════════════
        # MACOS-SPECIFIC PACKAGES
        # ════════════════════════════════════════════════════════════════
        coreutils
        findutils
        # Note: Apple SDK frameworks (Security, CoreFoundation, etc.) are
        # pulled in automatically by packages that need them at build time
      ];

    # Set up environment variables for development
    sessionVariables =
      {
        # Rust
        CARGO_HOME = "$HOME/.cargo";
        RUSTUP_HOME = "$HOME/.rustup";
      }
      // lib.optionalAttrs isLinux {
        # pkg-config (Linux only)
        PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.zlib.dev}/lib/pkgconfig";

        # OpenSSL (for Rust builds that need it)
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
      };

    # Ensure cargo bin is in PATH
    sessionPath = [
      "$HOME/.cargo/bin"
    ];
  };
}
