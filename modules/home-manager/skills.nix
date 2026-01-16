# Agent skills for Claude Code, OpenCode, and Codex
# Skills auto-update when running `nix flake update`
{inputs, ...}: let
  # Map skill inputs to their directory within the repo
  skills = {
    react-best-practices = {
      src = inputs.skill-react-best-practices;
      path = "skills/react-best-practices"; # path within the repo
    };
  };

  # Generate file entries for a skill across all agents
  mkSkillFiles = name: skill: {
    # Claude Code
    ".claude/skills/${name}".source = "${skill.src}/${skill.path}";

    # OpenCode
    ".config/opencode/skill/${name}".source = "${skill.src}/${skill.path}";

    # Codex
    ".codex/skills/${name}".source = "${skill.src}/${skill.path}";
  };

  # Merge all skill file entries
  allSkillFiles = builtins.foldl' (acc: name: acc // mkSkillFiles name skills.${name}) {} (builtins.attrNames skills);
in {
  home.file = allSkillFiles;
}
