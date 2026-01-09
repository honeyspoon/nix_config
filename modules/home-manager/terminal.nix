{config, ...}: let
  opencodeBellContextPath = "${config.xdg.configHome}/opencode/opencode-bell.md";

  # Mirror OpenCode's defaults, plus our global context file.
  opencodeDefaultContextPaths = [
    opencodeBellContextPath
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

  opencodeConfig = {
    contextPaths = opencodeDefaultContextPaths;

    # Make sure tool execution uses your login shell.
    shell = {
      path = "/bin/zsh";
      args = ["-l"];
    };

    # Keep the default data dir (".opencode") unless you want to change it.
    autoCompact = true;
  };
in {
  xdg.configFile."ghostty/config".text = ''
    # Make terminal bells noticeable when Ghostty is unfocused.
    # - attention: bounce dock icon
    # - title: show a 🔔 in the title
    bell-features = attention,title
  '';

  # OpenCode reads config from ~/.opencode.json or ~/.config/opencode/.opencode.json
  home.file.".opencode.json".text = builtins.toJSON opencodeConfig;

  # Small global context file that teaches the assistant to "ping" you.
  xdg.configFile."opencode/opencode-bell.md".text = ''
    # Attention bell

    When you are about to WAIT for user input (a question, a choice, confirmation, or approval), output a terminal bell character exactly once on its own line:

    \a

    Then ask the question / request the confirmation.

    Also output \a once when you are completely done and no further user input is required.
  '';
}
