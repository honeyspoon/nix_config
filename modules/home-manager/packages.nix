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
        fnm # fast node manager (nvm alternative)

        # Global npm packages (via nixpkgs nodePackages)
        # Note: typescript/prettier provided via wrangler deps and treefmt
        nodePackages.pnpm
        nodePackages.yarn
        nodePackages.npm-check-updates # ncu - update package.json deps
        nodePackages.typescript-language-server
        nodePackages.eslint
        nodePackages.vscode-langservers-extracted # html/css/json/eslint LSPs
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.graphql-language-service-cli
        nodePackages.svelte-language-server
        nodePackages."@astrojs/language-server"
        nodePackages.vercel # vercel CLI
        nodePackages.wrangler # cloudflare workers CLI (includes typescript, prettier, dotenv-cli)
        nodePackages.firebase-tools
        nodePackages.concurrently # run multiple commands
        nodePackages.nodemon # auto-restart on changes
        nodePackages.pm2 # process manager
        nodePackages.serve # static file server
        nodePackages.http-server # another static server

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
        tiger-cli # TimescaleDB/Tiger Cloud CLI with MCP server

        # ══════════════════════════════════════════════════════════════════
        # CLI TOOLS
        # NOTE: btop, htop, jq are managed via programs.* modules
        # ══════════════════════════════════════════════════════════════════
        tree
        wget
        curl
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
        tailscale # VPN mesh network

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
        # NOTE: ripgrep managed via programs.ripgrep module
        # ══════════════════════════════════════════════════════════════════
        gnused
        gawk
        sd # sed alternative

        # ══════════════════════════════════════════════════════════════════
        # MODERN CLI REPLACEMENTS
        # NOTE: fd, bat, eza managed via programs.* modules
        # ══════════════════════════════════════════════════════════════════
        dust # du alternative
        duf # df alternative
        procs # ps alternative
        hyperfine # benchmarking
        oha # http load tester

        # ══════════════════════════════════════════════════════════════════
        # FILE MANAGEMENT
        # NOTE: yazi managed via programs.yazi module
        # ══════════════════════════════════════════════════════════════════
        xplr # file explorer
        broot # tree explorer

        # ══════════════════════════════════════════════════════════════════
        # GIT TOOLS
        # NOTE: git, lazygit, gh, delta managed via programs.* modules
        # ══════════════════════════════════════════════════════════════════
        git-lfs
        difftastic # structural diff
        git-absorb

        # ══════════════════════════════════════════════════════════════════
        # DEVOPS / CLOUD
        # NOTE: k9s managed via programs.k9s module
        # ══════════════════════════════════════════════════════════════════
        awscli2
        opentofu # terraform-compatible, open source
        pulumi
        kubectl
        kubectx
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
        semgrep # static analysis for many languages
        mkcert
        age # encryption
        sops

        # ══════════════════════════════════════════════════════════════════
        # MISC DEV TOOLS
        # NOTE: direnv managed via programs.direnv module
        # ══════════════════════════════════════════════════════════════════
        just # command runner
        nix-direnv # faster direnv for nix (used by programs.direnv)
        entr # file watcher
        watchexec
        act # GitHub Actions locally
        tokei # fast code stats (Rust)
        hexyl # hex viewer
        viu # image viewer in terminal

        # ══════════════════════════════════════════════════════════════════
        # TERMINAL TOOLS
        # NOTE: tmux, starship managed via programs.* modules
        # ══════════════════════════════════════════════════════════════════
        zellij
        fastfetch
        asciinema # terminal session recording
        asciinema-agg # generate GIFs from asciinema recordings

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
        llm-agents.claude-code # from llm-agents flake (newer than nixpkgs)
        # agent-browser # temporarily disabled - pnpm build failing
        ollama
        llm # CLI access to LLMs (simon willison)

        # ══════════════════════════════════════════════════════════════════
        # DOCUMENTATION & DIAGRAMS
        # ══════════════════════════════════════════════════════════════════
        d2 # modern diagram scripting language
        plantuml # UML diagrams from text
        graphviz # DOT graph visualization
        nodePackages.mermaid-cli # mermaid diagrams CLI (mmdc)

        # ══════════════════════════════════════════════════════════════════
        # RELEASE & CHANGELOG
        # ══════════════════════════════════════════════════════════════════
        git-cliff # changelog generator from commits

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
