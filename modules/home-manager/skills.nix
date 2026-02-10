# Agent skills for Claude Code, OpenCode, Codex, and other AI agents
#
# Two installation methods:
#   1. Nix flake inputs — vendored in nix store, auto-update via `nix flake update`
#   2. skills.sh registry — installed via `npx skills add`, declarative list below
#
# Run `install-skills` manually or let the activation hook handle it on switch.
{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # ══════════════════════════════════════════════════════════════════════
  # NIX-MANAGED SKILLS (flake inputs, symlinked from nix store)
  # ══════════════════════════════════════════════════════════════════════
  nixSkills = {
    react-best-practices = {
      src = inputs.skill-react-best-practices;
      path = "skills/react-best-practices";
    };
  };

  mkSkillFiles = name: skill: {
    ".claude/skills/${name}".source = "${skill.src}/${skill.path}";
    ".config/opencode/skill/${name}".source = "${skill.src}/${skill.path}";
    ".codex/skills/${name}".source = "${skill.src}/${skill.path}";
  };

  allNixSkillFiles = builtins.foldl' (acc: name: acc // mkSkillFiles name nixSkills.${name}) {} (
    builtins.attrNames nixSkills
  );

  # ══════════════════════════════════════════════════════════════════════
  # SKILLS.SH REGISTRY (installed via npx skills add)
  # Add new skills here — they'll be installed on next switch or `install-skills`
  # ══════════════════════════════════════════════════════════════════════
  #   source = "github-owner/repo"
  #   skill  = skill name within the repo (optional, defaults to attrset key)
  skillsRegistry = {
    rust-best-practices = {
      source = "apollographql/skills";
    };
    remotion-best-practices = {
      source = "remotion-dev/skills";
      skill = "remotion";
    };
    tanstack-query = {
      source = "jezweb/claude-skills";
    };
    tanstack-router = {
      source = "jezweb/claude-skills";
    };
    tanstack-table = {
      source = "jezweb/claude-skills";
    };
    tanstack-form = {
      source = "exceptionless/exceptionless";
    };
    zod = {
      source = "pproenca/dot-skills";
    };
    framer-motion-best-practices = {
      source = "pproenca/dot-skills";
    };
    find-skills = {
      source = "vercel-labs/skills";
    };
    frontend-design = {
      source = "vercel-labs/skills";
    };
    webapp-testing = {
      source = "anthropics/skills";
    };
  };

  # Generate the install command for a single skill
  mkInstallCmd = name: cfg: let
    skillFlag = cfg.skill or name;
  in ''
    echo "  -> ${name} (${cfg.source})"
    npx -y skills add "${cfg.source}" \
      --skill "${skillFlag}" \
      --global --agent '*' --yes 2>/dev/null || echo "     [warn] failed to install ${name}"
  '';

  installScript = pkgs.writeShellScriptBin "install-skills" ''
    set -euo pipefail

    echo "Installing agent skills from nix-config registry..."
    echo ""

    # Check network connectivity
    if ! ${pkgs.curl}/bin/curl -sf --max-time 5 https://github.com > /dev/null 2>&1; then
      echo "[skip] No network connectivity — run 'install-skills' later"
      exit 0
    fi

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkInstallCmd skillsRegistry)}

    echo ""
    echo "Updating all skills to latest versions..."
    npx -y skills update 2>/dev/null || echo "[warn] skills update failed"

    echo ""
    echo "Done. Run 'npx skills list --global' to verify."
  '';
in {
  home = {
    # Nix-managed skill files (symlinked from store)
    file = allNixSkillFiles;

    # install-skills script on PATH
    packages = [installScript];

    # Auto-install on home-manager switch (runs after files are linked)
    activation.installSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Run in background to avoid blocking the switch
      if command -v npx >/dev/null 2>&1; then
        ${installScript}/bin/install-skills >/dev/null 2>&1 &
      fi
    '';
  };
}
