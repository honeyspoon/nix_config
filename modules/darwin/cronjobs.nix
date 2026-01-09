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

    notify() {
      local message="$1"
      /usr/bin/osascript -e "display notification \"$message\" with title \"nix sync\""
    }

    run_step() {
      local name="$1"
      shift
      if ! "$@"; then
        local status=$?
        notify "$name failed (exit $status). See ${logsDir}/nix-sync.*.log"
        exit $status
      fi
    }

    flake_dir="${primaryUserHome}/nix-config"
    flake_path="${primaryUserHome}/nix-config#abder-macbook"

    darwin_rebuild="/run/current-system/sw/bin/darwin-rebuild"
    if [ ! -x "$darwin_rebuild" ]; then
      darwin_rebuild="$(command -v darwin-rebuild || true)"
    fi

    if [ -z "$darwin_rebuild" ]; then
      notify "darwin-rebuild not found; cannot sync nix config"
      exit 127
    fi

    # Do "update" work once per day at 03:00, while "apply" runs hourly.
    now_hour="$(/bin/date +%H)"
    now_weekday="$(/bin/date +%u)" # 1..7 (Mon..Sun)

    if [ "$now_hour" = "03" ]; then
      if [ -d "$flake_dir" ]; then
        run_step "nix flake update" /bin/sh -lc "cd \"$flake_dir\" && nix flake update"
        run_step "nix flake check" /bin/sh -lc "cd \"$flake_dir\" && nix flake check -L"
      fi

      # Homebrew casks are prebuilt binaries; keep formula upgrades manual.
      if command -v brew >/dev/null 2>&1; then
        run_step "brew update" brew update
        run_step "brew upgrade (casks)" brew upgrade --cask --greedy
      fi

      # Rust toolchain auto-update (downloads toolchain; no compilation).
      if [ -x "${rustupBin}" ]; then
        run_step "rustup update" "${rustupBin}" update stable
      fi

      # Weekly pip self-update (Sunday @ 03:00)
      if [ "$now_weekday" = "7" ] && command -v python3 >/dev/null 2>&1; then
        run_step "pip upgrade" python3 -m pip install --upgrade pip
      fi

      # npm global updates require node; try to run via Homebrew nvm.
      if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
        run_step "npm update" /bin/sh -lc 'set -euo pipefail; export NVM_DIR="$HOME/.nvm"; . /opt/homebrew/opt/nvm/nvm.sh; nvm use --lts >/dev/null; npm update -g'
      fi
    fi

    # Apply your nix-darwin config hourly (requires passwordless sudo for unattended runs)
    if ! sudo -n "$darwin_rebuild" switch --flake "$flake_path"; then
      status=$?
      notify "darwin-rebuild switch needs sudo (exit $status). Run manually: sudo darwin-rebuild switch --flake $flake_path"
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
      name = "cron-mantis-pull";
      command = "if [ -d ${mantisDir}/.git ]; then cd ${mantisDir} && git pull; else echo 'mantis: not a git repo' 1>&2; fi";
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
