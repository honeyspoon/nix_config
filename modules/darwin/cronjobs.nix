{
  config,
  lib,
  pkgs,
  ...
}: let
  bash = "${pkgs.bash}/bin/bash";

  primaryUser = config.system.primaryUser or "abder";
  primaryUserHome = config.users.users.${primaryUser}.home or "/Users/${primaryUser}";

  logsDir = "${primaryUserHome}/Library/Logs";

  envPath = "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin";

  mkUserAgent = {
    name,
    command,
    startCalendarInterval ? null,
    startInterval ? null,
  }: {
    ${name} = {
      serviceConfig =
        {
          ProgramArguments = [
            bash
            "-lc"
            command
          ];

          EnvironmentVariables = {
            SHELL = "/bin/bash";
            PATH = envPath;
          };

          StandardOutPath = "${logsDir}/${name}.log";
          StandardErrorPath = "${logsDir}/${name}.err.log";
        }
        // lib.optionalAttrs (startCalendarInterval != null) {
          StartCalendarInterval = startCalendarInterval;
        }
        // lib.optionalAttrs (startInterval != null) {
          StartInterval = startInterval;
        };
    };
  };

  nixSyncScript = pkgs.writeShellScript "nix-sync" ''
    set -euo pipefail

    export PATH="${envPath}"

    flake_path="${primaryUserHome}/nix-config#abder-macbook"

    darwin_rebuild="/run/current-system/sw/bin/darwin-rebuild"
    if [ ! -x "$darwin_rebuild" ]; then
      darwin_rebuild="$(command -v darwin-rebuild || true)"
    fi

    if [ -z "$darwin_rebuild" ]; then
      /usr/bin/osascript -e "display notification \"darwin-rebuild not found; cannot sync nix config\" with title \"nix sync\""
      exit 127
    fi

    # This uses sudo non-interactively. If you haven't configured NOPASSWD
    # for darwin-rebuild, it will fail and you'll get a notification.
    if ! sudo -n "$darwin_rebuild" switch --flake "$flake_path"; then
      status=$?
      /usr/bin/osascript -e "display notification \"darwin-rebuild failed (exit $status). See ${logsDir}/nix-sync.*.log\" with title \"nix sync\""
      exit $status
    fi
  '';

  nixSyncAgent = {
    "nix-sync" = {
      serviceConfig = {
        ProgramArguments = ["${nixSyncScript}"];

        EnvironmentVariables = {
          PATH = envPath;
        };

        # Run at minute 0 of every hour
        StartCalendarInterval = [{Minute = 0;}];

        StandardOutPath = "${logsDir}/nix-sync.log";
        StandardErrorPath = "${logsDir}/nix-sync.err.log";
      };
    };
  };

  mantisDir = "${primaryUserHome}/mantis";
  wtDir = "${primaryUserHome}/wt";
  ceoDir = "${primaryUserHome}/ceo.ca";

  cleanRustScript = "${primaryUserHome}/clean_rust.sh";
  rustupBin = "${primaryUserHome}/.cargo/bin/rustup";
  stockPickCommand = "cd ${ceoDir} && /opt/homebrew/bin/python3 stock_pick.py >> stock_pick_cron.log 2>&1";
in {
  # macOS equivalent of cron: launchd jobs
  launchd.user.agents =
    {}
    // mkUserAgent {
      name = "cron-pip-upgrade";
      command = "python3 -m pip install --upgrade pip";
      startCalendarInterval = [
        {
          Weekday = 0;
          Hour = 0;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-mantis-pull";
      command = "cd ${mantisDir} && git pull";
      startInterval = 300;
    }
    // mkUserAgent {
      name = "cron-pkill-nvim";
      command = "pkill nvim";
      startCalendarInterval = [
        {
          Hour = 12;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-clean-rust";
      command = "cd ${wtDir} && ${cleanRustScript}";
      startCalendarInterval = [
        {
          Hour = 9;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-stock-pick";
      command = stockPickCommand;
      startCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-rustup-update";
      command = "${rustupBin} update stable";
      startCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-npm-update";
      command = "npm update -g";
      startCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-kill-rust-analyzer";
      command = "pkill rust-analyzer";
      startCalendarInterval = [{Minute = 0;}];
    }
    // mkUserAgent {
      name = "cron-kill-rift";
      command = "pkill rift";
      startCalendarInterval = [{Minute = 0;}];
    }
    // nixSyncAgent;
}
