# Scheduled tasks (cron jobs)
# macOS: uses launchd (in modules/darwin/cronjobs.nix)
# Linux: uses systemd user timers (this file)
{
  lib,
  pkgs,
  user,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  mantisDir = "${user.home}/mantis";
in {
  # Linux: systemd user services and timers
  systemd.user = lib.mkIf isLinux {
    services = {
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

      # Kill nvim daily at noon
      cron-pkill-nvim = {
        Unit = {
          Description = "Kill nvim processes";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.procps}/bin/pkill nvim || true";
        };
      };

      # Kill rust-analyzer hourly
      cron-kill-rust-analyzer = {
        Unit = {
          Description = "Kill rust-analyzer processes";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.procps}/bin/pkill rust-analyzer || true";
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
