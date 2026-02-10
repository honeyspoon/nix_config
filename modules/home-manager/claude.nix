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
  datadogMcpWrapper = pkgs.writeShellScript "datadog-mcp-wrapper" ''
    CACHE_FILE="$HOME/.cache/sops-secrets/decrypted.json"
    if [ -f "$CACHE_FILE" ]; then
      export DATADOG_API_KEY=$(${pkgs.jq}/bin/jq -r '.datadog_api_key // empty' "$CACHE_FILE")
      export DATADOG_APP_KEY=$(${pkgs.jq}/bin/jq -r '.datadog_app_key // empty' "$CACHE_FILE")
      export DD_SITE=$(${pkgs.jq}/bin/jq -r '.datadog_site // "datadoghq.com"' "$CACHE_FILE")
    fi
    exec npx -y @winor30/mcp-server-datadog "$@"
  '';

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
        args = ["mcp" "start"];
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
