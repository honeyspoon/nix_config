{
  lib,
  pkgs,
  user,
  ...
}: let
  secretsFile = ../../secrets/secrets.yaml;
  secretsPath = "${user.home}/nix-config/secrets/secrets.yaml";
  ageKeyFile = "${user.home}/.config/sops/age/keys.txt";
in {
  # Decrypt secrets directly in shell init (workaround for sops-nix launchd PATH issue on macOS)
  programs.zsh.initContent = lib.mkIf (builtins.pathExists secretsFile) (
    lib.mkAfter ''
            # Load secrets from sops-encrypted file
            if [ -r "${secretsPath}" ] && [ -r "${ageKeyFile}" ]; then
              _load_sops_secret() {
                local key="$1"
                ${pkgs.sops}/bin/sops -d --extract '["'"$key"'"]' "${secretsPath}" 2>/dev/null
              }

              # OpenAI
              if [ -z "''${OPENAI_API_KEY:-}" ]; then
                export OPENAI_API_KEY="$(_load_sops_secret openai_api_key)"
              fi

              # Vercel AI Gateway (for Anthropic)
              if [ -z "''${ANTHROPIC_CUSTOM_HEADERS:-}" ]; then
                _ai_gw_key="$(_load_sops_secret ai_gateway_api_key)"
                if [ -n "$_ai_gw_key" ]; then
                  export ANTHROPIC_CUSTOM_HEADERS="x-ai-gateway-api-key: Bearer $_ai_gw_key"
                fi
                unset _ai_gw_key
              fi

              # Datadog
              if [ -z "''${DATADOG_API_KEY:-}" ]; then
                export DATADOG_API_KEY="$(_load_sops_secret datadog_api_key)"
              fi
              if [ -z "''${DATADOG_APP_KEY:-}" ]; then
                export DATADOG_APP_KEY="$(_load_sops_secret datadog_app_key)"
              fi
              if [ -z "''${DD_SITE:-}" ]; then
                export DD_SITE="$(_load_sops_secret datadog_site)"
              fi

              # Dogshell (Datadog CLI `dog`) config
              if [ ! -e "$HOME/.dogrc" ] && [ -n "''${DATADOG_API_KEY:-}" ] && [ -n "''${DATADOG_APP_KEY:-}" ]; then
                umask 077
                api_host="https://api.''${DD_SITE:-datadoghq.com}"
                printf '%s\n' \
                  "[Connection]" \
                  "apikey = ''${DATADOG_API_KEY}" \
                  "appkey = ''${DATADOG_APP_KEY}" \
                  "api_host = ''${api_host}" \
                  >"$HOME/.dogrc"
                chmod 600 "$HOME/.dogrc" 2>/dev/null || true
              fi

              # === SSH Hosts Config (from sops secrets) ===
              _ssh_hosts_config="$HOME/.ssh/config.d/hosts.conf"
              mkdir -p "$HOME/.ssh/config.d"

              # Regenerate SSH hosts config from secrets
              _perf_bench_host="$(_load_sops_secret ssh_perf_bench_host)"
              _zuck_test_host="$(_load_sops_secret ssh_zuck_test_host)"
              _gpu_test_host="$(_load_sops_secret ssh_gpu_test_host)"
              _abder_dev_host="$(_load_sops_secret ssh_abder_dev_host)"
              _abder_dev_instance="$(_load_sops_secret ssh_abder_dev_instance)"
              _ssm_instance="$(_load_sops_secret ssh_ssm_instance)"

              cat > "$_ssh_hosts_config" << SSHEOF
      # Auto-generated from sops secrets - do not edit manually
      # Regenerated on each shell init

      Host perf_bench
        HostName $_perf_bench_host
        User ec2-user
        IdentityFile ~/.ssh/abder.pem

      Host zuck_test
        HostName $_zuck_test_host
        User ec2-user
        IdentityFile ~/.ssh/abder.pem

      Host gpu_test
        HostName $_gpu_test_host
        User ec2-user
        IdentityFile ~/.ssh/abder.pem

      Host $_ssm_instance
        User ec2-user
        ProxyCommand ~/.ssh/ssm-proxy.sh %h %p
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null

      Host abder-dev
        HostName $_abder_dev_host
        User abder
        IdentityFile ~/.ssh/dev.pem
        ProxyCommand sh -c 'STATE=\$(aws ec2 describe-instances --region ca-central-1 --instance-ids $_abder_dev_instance --query "Reservations[0].Instances[0].State.Name" --output text); if [ "\$STATE" = "stopped" ]; then echo "Starting instance..." >&2; aws ec2 start-instances --region ca-central-1 --instance-ids $_abder_dev_instance >&2; aws ec2 wait instance-running --region ca-central-1 --instance-ids $_abder_dev_instance >&2; sleep 15; fi; nc %h %p'
      SSHEOF

              chmod 600 "$_ssh_hosts_config"
              unset _perf_bench_host _zuck_test_host _gpu_test_host _abder_dev_host _abder_dev_instance _ssm_instance _ssh_hosts_config

              unset -f _load_sops_secret
            fi
    ''
  );
}
