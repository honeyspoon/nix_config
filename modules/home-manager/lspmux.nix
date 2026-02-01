# lspmux - LSP multiplexer service
# Shares a single LSP server instance between multiple editors
{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (pkgs) lspmux;

  lspmuxConfig = ''
    # lspmux configuration
    # See: https://codeberg.org/p2502/lspmux

    # Instance timeout in seconds (default: 300)
    instance_timeout = 600

    # Garbage collection interval in seconds
    gc_interval = 60

    # Listen address for the server (TCP: array format)
    listen = ["127.0.0.1", 27631]

    # Connection address for clients
    connect = ["127.0.0.1", 27631]

    # Pass specific environment variables to LSP servers
    # Explicitly exclude CARGO_HOME and RUSTUP_HOME to prevent rustup proxy issues
    pass_environment = [
      "HOME",
      "USER",
      "PATH",
      "LANG",
      "LC_*",
      "TERM",
      "COLORTERM",
      "XDG_*",
      "SSH_AUTH_SOCK",
      "RUST_BACKTRACE",
      "RUST_LOG"
    ]
  '';
in {
  # Linux: config at ~/.config/lspmux/config.toml
  xdg.configFile."lspmux/config.toml" = lib.mkIf isLinux {
    text = lspmuxConfig;
  };

  # macOS: config at ~/Library/Application Support/lspmux/config.toml
  home.file."Library/Application Support/lspmux/config.toml" = lib.mkIf isDarwin {
    text = lspmuxConfig;
  };

  # Linux: systemd user service
  systemd.user.services.lspmux = lib.mkIf isLinux {
    Unit = {
      Description = "lspmux - LSP multiplexer server";
      After = ["network.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lspmux}/bin/lspmux server";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # Shell aliases for convenience
  programs.zsh.shellAliases = {
    lspmux-status = "lspmux status";
    lspmux-reload = "lspmux reload";
  };
}
