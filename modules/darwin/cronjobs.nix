{pkgs, ...}: let
  bash = "${pkgs.bash}/bin/bash";

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
            PATH = "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin";
          };

          StandardOutPath = "/Users/abder/Library/Logs/${name}.log";
          StandardErrorPath = "/Users/abder/Library/Logs/${name}.err.log";
        }
        // pkgs.lib.optionalAttrs (startCalendarInterval != null) {
          StartCalendarInterval = startCalendarInterval;
        }
        // pkgs.lib.optionalAttrs (startInterval != null) {
          StartInterval = startInterval;
        };
    };
  };

  nixSyncScript = pkgs.writeShellScript "nix-sync" ''
    set -euo pipefail

    export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

    # This uses sudo non-interactively. If you haven't configured NOPASSWD
    # for darwin-rebuild, it will fail and you'll get a notification.
    if ! sudo -n darwin-rebuild switch --flake "/Users/abder/nix-config#abder-macbook"; then
      status=$?
      /usr/bin/osascript -e "display notification \"darwin-rebuild failed (exit $status). See ~/Library/Logs/nix-sync.*.log\" with title \"nix sync\""
      exit $status
    fi
  '';

  nixSyncAgent = {
    "nix-sync" = {
      serviceConfig = {
        ProgramArguments = [nixSyncScript];

        EnvironmentVariables = {
          PATH = "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin";
        };

        # Run at minute 0 of every hour
        StartCalendarInterval = [{Minute = 0;}];

        StandardOutPath = "/Users/abder/Library/Logs/nix-sync.log";
        StandardErrorPath = "/Users/abder/Library/Logs/nix-sync.err.log";
      };
    };
  };
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
      command = "cd /Users/abder/mantis && git pull";
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
      name = "cron-brew-upgrade-nvim";
      command = "brew upgrade nvim";
      startCalendarInterval = [
        {
          Hour = 0;
          Minute = 1;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-clean-rust";
      command = "cd /Users/abder/wt && /Users/abder/clean_rust.sh";
      startCalendarInterval = [
        {
          Hour = 9;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-stock-pick";
      command = "cd /Users/abder/ceo.ca && /opt/homebrew/bin/python3 stock_pick.py >> stock_pick_cron.log 2>&1";
      startCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-rustup-update";
      command = "/Users/abder/.cargo/bin/rustup update stable";
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
