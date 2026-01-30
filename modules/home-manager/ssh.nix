# SSH configuration
# Sensitive hostnames are stored in sops and injected at shell init
{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;

  # 1Password SSH agent socket path differs by platform
  onePasswordAgent =
    if isDarwin
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";
in {
  programs.ssh = {
    enable = true;

    # Opt-out of deprecated default config behavior
    enableDefaultConfig = false;

    # Include additional configs
    includes =
      [
        # SSH hosts from sops secrets (generated at shell init)
        "~/.ssh/config.d/*"
      ]
      ++ lib.optionals isDarwin [
        "~/.orbstack/ssh/config"
      ];

    # Global settings only - host configs are generated from secrets
    extraConfig = ''
      # Use 1Password SSH agent
      IdentityAgent "${onePasswordAgent}"
    '';

    matchBlocks = {
      # Global defaults (replaces deprecated enableDefaultConfig)
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentitiesOnly = "yes";
        };
      };

      # SSM-based SSH for AWS EC2 instances (pattern-based, no sensitive data)
      "i-* mi-*" = {
        user = "ec2-user";
        proxyCommand = "~/.ssh/ssm-proxy.sh %h %p";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
    };
  };

  # SSM proxy script
  home.file.".ssh/ssm-proxy.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # SSM proxy for SSH connections to EC2 instances
      set -euo pipefail

      INSTANCE_ID="$1"
      PORT="$2"
      REGION="''${AWS_REGION:-us-east-1}"

      exec aws ssm start-session \
        --target "$INSTANCE_ID" \
        --document-name AWS-StartSSHSession \
        --parameters "portNumber=$PORT" \
        --region "$REGION"
    '';
  };
}
