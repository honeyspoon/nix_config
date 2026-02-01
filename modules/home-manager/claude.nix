# Claude Code CLI configuration
{config, ...}: let
  # Path to nix-provided rust-analyzer
  rustAnalyzerPath = "${config.home.profileDirectory}/bin/rust-analyzer";

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

    # LSP servers - use lspmux to share instances between editors
    lspServers = {
      rust-analyzer = {
        command = "lspmux";
        args = ["--server-path" rustAnalyzerPath];
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
    };
  };
in {
  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
}
