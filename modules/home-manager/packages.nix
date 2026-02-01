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
        nodejs_24
        bun
        deno
        nodePackages.pnpm
        nodePackages.typescript
        nodePackages.typescript-language-server
        fnm # fast node manager (nvm alternative)

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
        wireshark-cli # tshark only, saves ~1GB vs GUI version
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
        opentofu # terraform-compatible, open source
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
        xh # modern httpie alternative (faster, Rust)
        grpcurl
        websocat

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
        nix-direnv # faster direnv for nix
        entr # file watcher
        watchexec
        act # GitHub Actions locally
        tokei # fast code stats (Rust)
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
        # Package management & exploration
        comma # run programs without installing (", program")
        nix-tree # interactive dependency viewer
        nix-diff # explain derivation differences
        nix-du # visualize store disk usage
        nvd # compare nix generations
        nix-prefetch-git
        nix-output-monitor # nom - better build output
        manix # nix documentation search
        nix-init # generate packages from URLs
        nurl # generate fetcher calls from URLs
        nix-melt # explore nix flake inputs
        cachix # binary cache

        # Formatters & linters
        nixfmt-rfc-style
        statix # linter with fixes
        deadnix # find unused code

        # Language server (nil is fast/reliable, nixd adds 600MB for LLVM)
        nil

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

        # ══════════════════════════════════════════════════════════════════
        # LSP TOOLS
        # ══════════════════════════════════════════════════════════════════
        lspmux # share LSP instances between editors
      ]
      ++ lib.optionals isLinux [
        # ════════════════════════════════════════════════════════════════
        # LINUX-SPECIFIC PACKAGES
        # ════════════════════════════════════════════════════════════════
        # Docker (CLI only - daemon needs system install)
        docker
        docker-buildx
        docker-credential-helpers

        # Compilers and build tools
        gcc
        # clang/llvm excluded - conflicts with gcc (ld.bfd)
        binutils
        patchelf
        nix-ld # run unpatched binaries
        gnupatch
        bison
        flex
        gettext

        # Additional build tools
        ccache
        bear # compilation database generator
        gdb
        valgrind
        perf-tools

        # System debugging
        strace
        ltrace
        lsof
        file
        sysstat # iostat, mpstat, etc
        iotop
        nethogs

        # System libraries (headers for compilation)
        glibc
        glibc.dev
        libcap
        ncurses
        ncurses.dev
        bzip2
        bzip2.dev
        xz.dev
        libxml2
        libxml2.dev
        libyaml
        expat
        expat.dev

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
    # NOTE: CARGO_HOME is intentionally NOT set - we use nix's rust toolchain
    # and don't want rust-analyzer to find rustup proxies at ~/.cargo/bin
    sessionVariables =
      {
      }
      // lib.optionalAttrs isLinux {
        # pkg-config (Linux only)
        PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.zlib.dev}/lib/pkgconfig";

        # OpenSSL (for Rust builds that need it)
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
      };

    # NOTE: ~/.cargo/bin is NOT added to PATH
    # We use nix's rust toolchain exclusively to avoid version conflicts
    # with rustup proxies (which fail for nightly toolchains without components)
    sessionPath = [];
  };
}
