{
  config,
  lib,
  ...
}: let
  opencodeDir = "${config.home.homeDirectory}/.opencode";
in {
  xdg.configFile."opencode/commands" = {
    source = ../../config/opencode/commands;
    recursive = true;
  };

  home.file = {
    ".opencode/package.json".source = ../../config/opencode/package.json;
    ".opencode/bun.lock".source = ../../config/opencode/bun.lock;
    ".opencode/.gitignore".source = ../../config/opencode/.gitignore;

    ".opencode/skill" = {
      source = ../../config/opencode/skill;
      recursive = true;
    };

    # User commands (Ctrl+K)
    ".opencode/commands" = {
      source = ../../config/opencode/commands;
      recursive = true;
    };
  };

  # Best-effort: if plugin deps are missing, install them.
  # This keeps the repo clean (we don’t commit node_modules) while still being usable.
  home.activation.opencodeInstallDeps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "${opencodeDir}/node_modules" ]; then
      if command -v bun >/dev/null 2>&1; then
        (
          set -e
          cd "${opencodeDir}"
          bun install --frozen-lockfile
        ) || {
          msg="OpenCode: bun install failed in ${opencodeDir}"
          printf '%s\n' "$msg" >&2
          if command -v /usr/bin/osascript >/dev/null 2>&1; then
            /usr/bin/osascript -e "display notification \"$msg\" with title \"Home Manager\""
          fi
        }
      else
        msg="OpenCode: bun not found; cannot install ~/.opencode/node_modules"
        printf '%s\n' "$msg" >&2
      fi
    fi
  '';
}
