# Claude Code CLI configuration
_: let
  claudeSettings = {
    defaultMode = "bypassPermissions";

    # Remove Claude attribution in git commits/PRs.
    attribution = {
      commit = "";
      pr = "";
    };

    # MCP servers
    mcpServers = {
      datadog = {
        command = "npx";
        args = [
          "-y"
          "@winor30/mcp-server-datadog"
        ];
        # Reads from environment: DATADOG_API_KEY, DATADOG_APP_KEY, DD_SITE
      };
    };
  };
in {
  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
}
