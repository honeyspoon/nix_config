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

  # PATH for launchd agents - nix paths FIRST to avoid rustup/homebrew conflicts
  envPath = "/etc/profiles/per-user/${primaryUser}/bin:${primaryUserHome}/.opencode/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin";

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
  lspmux = "${pkgs.lspmux}/bin/lspmux";
in {
  # macOS equivalent of cron: launchd jobs
  launchd.user.agents =
    {
      # lspmux server - LSP multiplexer (long-running service)
      lspmux-server = {
        serviceConfig = {
          ProgramArguments = [
            lspmux
            "server"
          ];
          EnvironmentVariables = {
            PATH = envPath;
            HOME = primaryUserHome;
          };
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "${logsDir}/lspmux.log";
          StandardErrorPath = "${logsDir}/lspmux.err.log";
        };
      };
    }
    // mkUserAgent {
      name = "cron-mantis-pull";
      command = "if [ -d ${mantisDir}/.git ]; then cd ${mantisDir} && git pull; else echo 'mantis: not a git repo' 1>&2; fi";
      startInterval = 300;
    }
    // mkUserAgent {
      name = "cron-opencode-upgrade";
      command = "if [ ! -x $HOME/.opencode/bin/opencode ]; then ${pkgs.curl}/bin/curl -fsSL https://opencode.ai/install | ${pkgs.bash}/bin/bash || true; fi; if [ -x $HOME/.opencode/bin/opencode ]; then $HOME/.opencode/bin/opencode upgrade || true; rm -rf $HOME/.cache/opencode/node_modules $HOME/.cache/opencode/bun.lock; $HOME/.opencode/bin/opencode debug config >/dev/null 2>&1 || true; fi";
      startCalendarInterval = [
        {
          Hour = 3;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-pkill-nvim";
      command = "pkill -u ${primaryUser} -x nvim || true";
      startCalendarInterval = [
        {
          Hour = 12;
          Minute = 0;
        }
      ];
    }
    // mkUserAgent {
      name = "cron-kill-rust-analyzer";
      command = "pkill -u ${primaryUser} -x rust-analyzer || true";
      startCalendarInterval = [{Minute = 0;}];
    };
}
