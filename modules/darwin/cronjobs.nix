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
      name = "cron-mas-install";
      command = "if command -v mas >/dev/null 2>&1; then if mas account >/dev/null 2>&1; then for app in 1569813296 1500855883 1582358382 1474276998 409183694 409201541 1624912180 899247664 6739973551 497799835 6748351905; do mas install \"$app\" >/dev/null 2>&1 || true; done; else echo 'mas: not signed in; skipping installs' >&2; fi; fi";
      startCalendarInterval = [
        {
          Hour = 3;
          Minute = 30;
        }
      ];
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
