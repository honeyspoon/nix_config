# lspmux - LSP multiplexer service
# Shares a single LSP server instance between multiple editors
{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (pkgs) lspmux;
in {
  # Create config directory and default config
  xdg.configFile."lspmux/config.toml".text = ''
    # lspmux configuration
    # See: https://codeberg.org/p2502/lspmux

    # Instance timeout in seconds (default: 300)
    instance_timeout = 600

    # Garbage collection interval in seconds
    gc_interval = 60

    # Listen address for the server
    listen = "127.0.0.1:27631"

    # Connection address for clients
    connect = "127.0.0.1:27631"
  '';

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
