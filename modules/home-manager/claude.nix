# Claude Code CLI configuration
{
  config,
  pkgs,
  ...
}: let
  # Paths to nix-provided tools
  rustAnalyzerPath = "${config.home.profileDirectory}/bin/rust-analyzer";
  tigerPath = "${pkgs.tiger-cli}/bin/tiger";

  # Wrapper script to run MCP servers with sops-decrypted env vars
  # Reads from cached secrets to avoid slow interactive shell init
  datadogMcpWrapper = import ./lib/datadog-mcp-wrapper.nix {inherit pkgs;};

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
        # Use wrapper script that loads env vars from sops cache (avoids slow interactive shell)
        command = "${datadogMcpWrapper}";
        args = [];
      };
      tiger = {
        command = tigerPath;
        args = [
          "mcp"
          "start"
          "stdio"
        ];
      };
    };

    # LSP servers - use lspmux to share instances between editors
    lspServers = {
      rust-analyzer = {
        command = "lspmux";
        args = [
          "--server-path"
          rustAnalyzerPath
        ];
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
    };
  };
in {
  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
}
