# Homebrew packages, casks, and Mac App Store apps
_: {
  homebrew = {
    enable = true;

    # Keep manual brew commands predictable too.
    global.autoUpdate = false;

    onActivation = {
      # Keep `darwin-rebuild switch` fast and predictable.
      # Updates/upgrades run from the `nix-sync` launchd job instead.
      autoUpdate = false;

      # Avoid Homebrew building from source during activation.
      # Upgrade explicitly when you want with `brew upgrade --force-bottle`.
      upgrade = false;

      # Use "uninstall" instead of "zap" to preserve dependencies
      # (cargo-lambda needs zig, ueberzugpp needs chafa/libsixel/spdlog/tbb)
      cleanup = "uninstall";
    };

    taps = [
      "acsandmann/tap"
      "armcord/armcord"
      "aws/tap"
      "brewforge/extras"
      "cargo-lambda/cargo-lambda"
      "charmbracelet/tap"
      "datarootsio/tf-profile"
      "domoritz/tap"
      "felixkratz/formulae"
      "filosottile/musl-cross"
      "hashicorp/tap"
      "homebrew/cask"
      "homebrew/services"
      "joshmedeski/sesh"
      "jstkdng/programs"
      "libsql/sqld"
      "messense/macos-cross-toolchains"
      "mongodb/brew"
      "nikitabobko/tap"
      "notwadegrimridge/brew"
      "opencode-ai/tap"
      "oven-sh/bun"
      "owasp-amass/amass"
      "pulumi/tap"
      "shshemi/tabiew"
      "steipete/tap"
      "tursodatabase/tap"
      "withgraphite/tap"
    ];

    # NOTE: Many CLI tools are provided by nix (packages.nix) and removed from here
    # to avoid version conflicts. Homebrew is used for:
    # - macOS-specific tools and libs
    # - GUI apps via casks
    # - Tools not available or broken in nixpkgs
    brews = [
      # ══════════════════════════════════════════════════════════════════
      # MACOS-SPECIFIC / NOT IN NIX
      # ══════════════════════════════════════════════════════════════════
      "borders" # macOS window borders
      "displayplacer" # macOS display management
      "mas" # Mac App Store CLI
      "pngpaste" # macOS clipboard
      "showkey" # macOS key debugging
      "terminal-notifier" # macOS notifications

      # ══════════════════════════════════════════════════════════════════
      # MULTIMEDIA / GRAPHICS (complex deps, better from brew)
      # ══════════════════════════════════════════════════════════════════
      "ffmpeg"
      "imagemagick"
      "vips"

      # ══════════════════════════════════════════════════════════════════
      # SECURITY / REVERSE ENGINEERING
      # ══════════════════════════════════════════════════════════════════
      "amass"
      "binwalk"
      "capstone"
      "ghidra"
      "gobuster"
      "nmap"
      "proxychains-ng"
      "radare2"
      "wireshark"

      # ══════════════════════════════════════════════════════════════════
      # DATABASE TOOLS
      # ══════════════════════════════════════════════════════════════════
      "mongocli"
      "mongodb-atlas-cli"
      "mongodb-database-tools"
      "mongosh"
      "postgresql@14" # keep older version for compatibility
      "sqld"

      # ══════════════════════════════════════════════════════════════════
      # TERRAFORM ECOSYSTEM (hashicorp-specific)
      # ══════════════════════════════════════════════════════════════════
      "terraform"
      "terraform-docs"
      "tf-profile"
      "tflint"
      "tfsec"

      # ══════════════════════════════════════════════════════════════════
      # CROSS-COMPILATION TOOLCHAINS
      # ══════════════════════════════════════════════════════════════════
      "musl-cross"
      "x86_64-linux-gnu-binutils"

      # ══════════════════════════════════════════════════════════════════
      # CARGO EXTENSIONS (not in nixpkgs or outdated)
      # ══════════════════════════════════════════════════════════════════
      "cargo-instruments" # macOS-specific
      "cargo-lambda"
      "cargo-udeps"

      # ══════════════════════════════════════════════════════════════════
      # MISC TOOLS (not in nix / brew-specific)
      # ══════════════════════════════════════════════════════════════════
      "aichat"
      "buf" # protobuf tooling
      "chezmoi"
      "crane" # container registry tool
      "d2" # diagram language
      "dep-tree"
      "evil-helix"
      "expect"
      "fswatch"
      "gcalcli"
      "glances"
      "gnuplot"
      "graphviz"
      "gum" # charm cli
      "hey" # http load testing
      "hivemind"
      "ipatool"
      "jenv" # java version manager
      "jj" # jujutsu vcs
      "jpdfbookmarks"
      "localstack"
      "mermaid-cli"
      "mods" # charm ai
      "neovim" # keep brew neovim for cask deps
      "opencode"
      "oxlint"
      "parquet-cli"
      "csv2arrow"
      "csv2parquet"
      "json2parquet"
      "pipx"
      "plantuml"
      "poetry"
      # powerlevel10k removed - using Starship prompt (managed by Stylix)
      "prek"
      "qemu"
      "railway"
      "rainfrog"
      "repomix"
      "rift"
      "scc"
      "sesh"
      "sqlfluff"
      "srt" # SRT streaming
      "sshpass"
      "tabiew"
      "telnet"
      "tesseract"
      "tesseract-lang"
      "turso"
      "typst"
      "ueberzugpp"
      "xidel"
      "zipkin"
      "zoxide"

      # ══════════════════════════════════════════════════════════════════
      # JAVA ECOSYSTEM
      # ══════════════════════════════════════════════════════════════════
      "openjdk"
      "openjdk@11"
      "openjdk@21"
      "cfr-decompiler"
      "procyon-decompiler"

      # ══════════════════════════════════════════════════════════════════
      # PYTHON (keep brew python for macOS tool compatibility)
      # ══════════════════════════════════════════════════════════════════
      {
        name = "python-packaging";
        link = false;
      }
      "python-tk@3.13"
      "python@3.11"
      "python@3.12"
      "python@3.13"
      "python@3.14"

      # ══════════════════════════════════════════════════════════════════
      # X11 STACK (for GUI apps that need it)
      # ══════════════════════════════════════════════════════════════════
      "xorg-server"
      "xauth"
      "xdotool"

      # ══════════════════════════════════════════════════════════════════
      # YT-DLP (avoid conflicts)
      # ══════════════════════════════════════════════════════════════════
      {
        name = "yt-dlp";
        link = false;
      }
    ];

    casks = [
      "5ire"
      "aerospace"
      "alacritty"
      "amethyst"
      "arc"
      "android-commandlinetools"
      "android-platform-tools"
      "android-studio"
      "armcord"
      "aws-vault-binary"
      "bitwarden"
      "bluesnooze"
      "burp-suite"
      "cakebrew"
      "cameracontroller"
      "charles"
      "chromium"
      "clickhouse"
      "codexbar"
      "cyberduck"
      "dbeaver-community"
      "emacs-app"
      "figma"
      "ghidra"
      "ghostty"
      "google-chrome"
      "gqrx"
      "graphql-playground"
      "halloy"
      "hammerspoon"
      "imhex"
      "insomnia"
      "iterm2"
      "itsycal"
      "jd-gui"
      "jordanbaird-ice"
      "karabiner-elements"
      "legcord"
      "lm-studio"
      "mactex"
      "master-pdf-editor"
      "miniconda"
      "mitmproxy"
      "mockoon"
      "musaicfm"
      "neovide-app"
      "ngrok"
      "notion"
      "obsidian"
      "openvisualtraceroute"
      "openvpn-connect"
      "orbstack"
      "pdfsam-basic"
      "pgadmin4"
      "pingplace"
      "pocket-casts"
      "reminders-menubar"
      "session-manager-plugin"
      "sioyek"
      "slack"
      "sloth"
      "spotify"
      "steam"
      "tailscale"
      "temurin"
      "tofu"
      "topnotch"
      "vlc"
      "vmware-fusion"
      "warp"
      "wezterm@nightly"
      "zoom"
      "zotero"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "CapCut" = 1500855883;
      "Dynamic wallpaper" = 1582358382;
      "HP Smart" = 1474276998;
      "Keynote" = 409183694;
      "Pages" = 409201541;
      "Speechify" = 1624912180;
      "TestFlight" = 899247664;
      "TranscribeTranslate" = 6739973551;
      "Xcode" = 497799835;
      "flowy" = 6748351905;
    };
  };
}
