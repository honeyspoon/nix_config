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

  mantisDir = "${primaryUserHome}/mantis";
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
      name = "cron-kill-rust-analyzer";
      command = "pkill rust-analyzer";
      startCalendarInterval = [{Minute = 0;}];
    };
}
