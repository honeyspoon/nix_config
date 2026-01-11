{config, ...}: let
  bellPath = "${config.xdg.configHome}/opencode/opencode-bell.md";

  opencodeConfig = {
    autoCompact = true;
    shell = {
      path = "/bin/zsh";
      args = ["-l"];
    };
    contextPaths = [
      bellPath
      ".github/copilot-instructions.md"
      ".cursorrules"
      ".cursor/rules/"
      "CLAUDE.md"
      "CLAUDE.local.md"
      "opencode.md"
      "opencode.local.md"
      "OpenCode.md"
      "OpenCode.local.md"
      "OPENCODE.md"
      "OPENCODE.local.md"
    ];
  };
in {
  xdg.configFile = {
    "opencode/opencode-bell.md".text = ''
      # Attention bell

      When you are about to WAIT for user input (a question, a choice, confirmation, or approval), output a terminal bell character exactly once on its own line:

      \a

      Then ask the question / request the confirmation.

      Also output \a once when you are completely done and no further user input is required.
    '';

    "opencode/.opencode.json".text = builtins.toJSON opencodeConfig;

    "opencode/commands" = {
      source = ../../config/opencode/commands;
      recursive = true;
    };

    "opencode/skill" = {
      source = ../../config/opencode/skill;
      recursive = true;
    };
  };
}
