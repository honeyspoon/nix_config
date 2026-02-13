# Scheduled tasks (cron jobs) and persistent services
# macOS: uses launchd (in modules/darwin/cronjobs.nix)
# Linux: uses systemd user timers and services (this file)
{
  lib,
  pkgs,
  user,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  mantisDir = "${user.home}/mantis";
  opencodeBin = "${user.home}/.opencode/bin/opencode";
in {
  # Linux: systemd user services and timers
  systemd.user = lib.mkIf isLinux {
    services = {
      # OpenCode web UI with built-in API server on port 4096
      # Note: `opencode web` includes the server, just also opens browser (which fails on headless)
      opencode-web = {
        Unit = {
          Description = "OpenCode Web UI and API Server";
          After = ["network.target"];
        };
        Service = {
          Type = "simple";
          # The browser open will fail on headless but the server still runs
          ExecStart = "${opencodeBin} web --hostname 0.0.0.0 --port 4096";
          Restart = "always";
          RestartSec = "5";
          Environment = [
            "PATH=${user.home}/.opencode/bin:${user.home}/.nix-profile/bin:/usr/bin:/bin"
            "HOME=${user.home}"
            "BROWSER="
          ];
          WorkingDirectory = "${user.home}";
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      # Pull mantis repo every 5 minutes
      cron-mantis-pull = {
        Unit = {
          Description = "Pull mantis git repository";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -lc 'if [ -d ${mantisDir}/.git ]; then cd ${mantisDir} && git pull; else echo \"mantis: not a git repo\" 1>&2; fi'";
        };
      };

      # Keep OpenCode updated (no source compilation; uses built-in upgrader)
      opencode-upgrade = {
        Unit = {
          Description = "Upgrade OpenCode";
          After = ["network.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -lc 'if [ ! -x ${opencodeBin} ]; then ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install | ${pkgs.bash}/bin/bash || true; fi; if [ -x ${opencodeBin} ]; then ${opencodeBin} upgrade || true; rm -rf $HOME/.cache/opencode/node_modules $HOME/.cache/opencode/bun.lock; ${opencodeBin} debug config >/dev/null 2>&1 || true; systemctl --user restart opencode-web.service >/dev/null 2>&1 || true; fi'";
        };
      };

      # Kill nvim daily at noon
      cron-pkill-nvim = {
        Unit = {
          Description = "Kill nvim processes";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.procps}/bin/pkill -u ${user.name} -x nvim || true";
        };
      };

      # Kill rust-analyzer hourly
      cron-kill-rust-analyzer = {
        Unit = {
          Description = "Kill rust-analyzer processes";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.procps}/bin/pkill -u ${user.name} -x rust-analyzer || true";
        };
      };
    };

    timers = {
      # Every 5 minutes
      cron-mantis-pull = {
        Unit = {
          Description = "Pull mantis repo timer";
        };
        Timer = {
          OnBootSec = "5min";
          OnUnitActiveSec = "5min";
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };

      # Daily early morning
      opencode-upgrade = {
        Unit = {
          Description = "Upgrade OpenCode timer";
        };
        Timer = {
          OnCalendar = "*-*-* 04:00:00";
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };

      # Daily at noon
      cron-pkill-nvim = {
        Unit = {
          Description = "Kill nvim timer";
        };
        Timer = {
          OnCalendar = "*-*-* 12:00:00";
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };

      # Hourly (on the hour)
      cron-kill-rust-analyzer = {
        Unit = {
          Description = "Kill rust-analyzer timer";
        };
        Timer = {
          OnCalendar = "*-*-* *:00:00";
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
  };
}
