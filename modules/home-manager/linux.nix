# Linux-specific configuration (Ubuntu/Debian apt packages)
{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;

  # Apt packages to install on Ubuntu/Debian
  # These are system-level dependencies that work better via apt
  aptPackages = [
    # Build essentials
    "build-essential"
    "pkg-config"
    "libssl-dev"
    "libffi-dev"
    "zlib1g-dev"
    "libbz2-dev"
    "libreadline-dev"
    "libsqlite3-dev"
    "libncursesw5-dev"
    "libxml2-dev"
    "libxmlsec1-dev"
    "liblzma-dev"

    # Graphics / UI libs (for GUI apps)
    "libgtk-3-dev"
    "libwebkit2gtk-4.1-dev"
    "libayatana-appindicator3-dev"
    "librsvg2-dev"

    # Audio/Video
    "libasound2-dev"
    "libpulse-dev"

    # Compression
    "liblz4-dev"
    "libzstd-dev"

    # Network
    "libcurl4-openssl-dev"

    # Database libs
    "libpq-dev"
    "libmysqlclient-dev"

    # System tools
    "software-properties-common"
    "apt-transport-https"
    "ca-certificates"
    "gnupg"
    "lsb-release"

    # Useful CLI tools not in nix or better via apt
    "xclip"
    "xsel"

    # Fonts
    "fonts-firacode"
    "fonts-jetbrains-mono"
    "fonts-noto"
    "fonts-noto-color-emoji"

    # Docker prerequisites (if not using nix docker)
    "containerd"
    "docker.io"
    "docker-compose"
  ];

  aptInstallScript = pkgs.writeShellScriptBin "install-apt-packages" ''
    set -euo pipefail

    # Only run on Debian/Ubuntu
    if ! command -v apt-get &>/dev/null; then
      echo "apt-get not found, skipping apt package installation"
      exit 0
    fi

    echo "Installing system packages via apt..."

    # Update package list
    sudo apt-get update -qq

    # Install packages (non-interactive)
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
      ${lib.concatStringsSep " \\\n      " aptPackages}

    echo "apt packages installed successfully!"
  '';
in {
  config = lib.mkIf isLinux {
    home.packages = [
      aptInstallScript
    ];

    # Create a convenient activation script hint
    home.file.".local/share/nix-config/install-apt-packages.sh" = {
      text = ''
        #!/usr/bin/env bash
        # Run this script to install system-level apt packages
        # Usage: bash ~/.local/share/nix-config/install-apt-packages.sh

        set -euo pipefail

        if ! command -v apt-get &>/dev/null; then
          echo "This script is for Ubuntu/Debian systems only"
          exit 1
        fi

        echo "=== Installing Ubuntu/Debian system packages ==="

        sudo apt-get update

        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
          ${lib.concatStringsSep " \\\n          " aptPackages}

        echo ""
        echo "=== System packages installed! ==="
        echo ""
        echo "You may also want to:"
        echo "  - Add your user to docker group: sudo usermod -aG docker $USER"
        echo "  - Install Rust via rustup: rustup default stable"
        echo "  - Log out and back in for group changes"
      '';
      executable = true;
    };
  };
}
