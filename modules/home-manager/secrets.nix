{
  lib,
  pkgs,
  user,
  ...
}: let
  secretsFile = ../../secrets/secrets.yaml;
  secretsPath = "${user.home}/nix-config/secrets/secrets.yaml";
  ageKeyFile = "${user.home}/.config/sops/age/keys.txt";
  cacheDir = "${user.home}/.cache/sops-secrets";
  cacheFile = "${cacheDir}/decrypted.json";
  arcExportDir = "${user.home}/.local/share/arc-export-decrypted";
in {
  # Decrypt secrets directly in shell init (workaround for sops-nix launchd PATH issue on macOS)
  # Optimized: decrypt once and cache, extract all values with jq
  programs.zsh.initContent = lib.mkIf (builtins.pathExists secretsFile) (
    lib.mkAfter ''
            # Load secrets from sops-encrypted file (cached for fast shell startup)
            if [ -r "${secretsPath}" ] && [ -r "${ageKeyFile}" ]; then
              _sops_cache="${cacheFile}"
              _sops_src="${secretsPath}"

              # Regenerate cache if secrets file is newer or cache doesn't exist
              if [ ! -f "$_sops_cache" ] || [ "$_sops_src" -nt "$_sops_cache" ]; then
                mkdir -p "${cacheDir}"
                chmod 700 "${cacheDir}"
                ${pkgs.sops}/bin/sops -d --output-type json "$_sops_src" > "$_sops_cache" 2>/dev/null
                chmod 600 "$_sops_cache"
              fi

              if [ -r "$_sops_cache" ]; then
                # Extract all secrets in one jq call
                eval "$(${pkgs.jq}/bin/jq -r '
                  @sh "
                    _openai_api_key=\(.openai_api_key // "")
                    _ai_gateway_api_key=\(.ai_gateway_api_key // "")
                    _datadog_api_key=\(.datadog_api_key // "")
                    _datadog_app_key=\(.datadog_app_key // "")
                    _datadog_site=\(.datadog_site // "")
                    _ssh_perf_bench_host=\(.ssh_perf_bench_host // "")
                    _ssh_zuck_test_host=\(.ssh_zuck_test_host // "")
                    _ssh_gpu_test_host=\(.ssh_gpu_test_host // "")
                    _ssh_abder_dev_host=\(.ssh_abder_dev_host // "")
                    _ssh_abder_dev_instance=\(.ssh_abder_dev_instance // "")
                    _ssh_ssm_instance=\(.ssh_ssm_instance // "")
                  "
                ' "$_sops_cache")"

                # Export environment variables (only if not already set)
                [ -z "''${OPENAI_API_KEY:-}" ] && export OPENAI_API_KEY="$_openai_api_key"

                if [ -z "''${ANTHROPIC_CUSTOM_HEADERS:-}" ] && [ -n "$_ai_gateway_api_key" ]; then
                  export ANTHROPIC_CUSTOM_HEADERS="x-ai-gateway-api-key: Bearer $_ai_gateway_api_key"
                fi

                [ -z "''${DATADOG_API_KEY:-}" ] && export DATADOG_API_KEY="$_datadog_api_key"
                [ -z "''${DATADOG_APP_KEY:-}" ] && export DATADOG_APP_KEY="$_datadog_app_key"
                [ -z "''${DD_SITE:-}" ] && export DD_SITE="$_datadog_site"

                # Dogshell config
                if [ ! -e "$HOME/.dogrc" ] && [ -n "$_datadog_api_key" ] && [ -n "$_datadog_app_key" ]; then
                  umask 077
                  printf '%s\n' \
                    "[Connection]" \
                    "apikey = $_datadog_api_key" \
                    "appkey = $_datadog_app_key" \
                    "api_host = https://api.''${_datadog_site:-datadoghq.com}" \
                    > "$HOME/.dogrc"
                  chmod 600 "$HOME/.dogrc" 2>/dev/null || true
                fi

                # SSH hosts config (only regenerate if cache was updated)
                _ssh_config="$HOME/.ssh/config.d/hosts.conf"
                if [ ! -f "$_ssh_config" ] || [ "$_sops_cache" -nt "$_ssh_config" ]; then
                  mkdir -p "$HOME/.ssh/config.d"
                  cat > "$_ssh_config" << SSHEOF
      # Auto-generated from sops secrets - do not edit manually

      Host perf_bench
        HostName $_ssh_perf_bench_host
        User ec2-user
        IdentityFile ~/.ssh/abder.pem

      Host zuck_test
        HostName $_ssh_zuck_test_host
        User ec2-user
        IdentityFile ~/.ssh/abder.pem

      Host gpu_test
        HostName $_ssh_gpu_test_host
        User ec2-user
        IdentityFile ~/.ssh/abder.pem

      Host $_ssh_ssm_instance
        User ec2-user
        ProxyCommand ~/.ssh/ssm-proxy.sh %h %p
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null

      Host abder-dev
        HostName $_ssh_abder_dev_host
        User abder
        IdentityFile ~/.ssh/dev.pem
        LocalForward 3000 localhost:3000
        LocalForward 3001 localhost:3001
        LocalForward 4000 localhost:4000
        LocalForward 5000 localhost:5000
        LocalForward 5432 localhost:5432
        LocalForward 5433 localhost:5433
        LocalForward 6379 localhost:6379
        LocalForward 8000 localhost:8000
        LocalForward 8080 localhost:8080
        LocalForward 8443 localhost:8443
        LocalForward 8978 localhost:8978
        LocalForward 9090 localhost:9090
        LocalForward 9000 localhost:9000
        ProxyCommand sh -c 'STATE=\$(aws ec2 describe-instances --region ca-central-1 --instance-ids $_ssh_abder_dev_instance --query "Reservations[0].Instances[0].State.Name" --output text); if [ "\$STATE" = "stopped" ]; then echo "Starting instance..." >&2; aws ec2 start-instances --region ca-central-1 --instance-ids $_ssh_abder_dev_instance >&2; aws ec2 wait instance-running --region ca-central-1 --instance-ids $_ssh_abder_dev_instance >&2; sleep 15; fi; nc %h %p'
      SSHEOF
                  chmod 600 "$_ssh_config"
                fi

                # Cleanup temporary variables
                unset _openai_api_key _ai_gateway_api_key _datadog_api_key _datadog_app_key _datadog_site
                unset _ssh_perf_bench_host _ssh_zuck_test_host _ssh_gpu_test_host
                unset _ssh_abder_dev_host _ssh_abder_dev_instance _ssh_ssm_instance _ssh_config

                # Export Arc browser data from sops (for Zen browser import)
                _arc_dir="${arcExportDir}"
                if [ ! -d "$_arc_dir" ] || [ "$_sops_cache" -nt "$_arc_dir/tabs.json" ]; then
                  mkdir -p "$_arc_dir"
                  chmod 700 "$_arc_dir"
                  ${pkgs.jq}/bin/jq -r '.arc_browser_tabs // "[]" | fromjson' "$_sops_cache" > "$_arc_dir/tabs.json" 2>/dev/null || true
                  ${pkgs.jq}/bin/jq -r '.arc_browser_extensions // "[]" | fromjson' "$_sops_cache" > "$_arc_dir/extensions.json" 2>/dev/null || true
                  ${pkgs.jq}/bin/jq -r '.arc_browser_spaces // "[]" | fromjson' "$_sops_cache" > "$_arc_dir/spaces.json" 2>/dev/null || true
                  ${pkgs.jq}/bin/jq -r '.arc_browser_bookmarks // "[]" | fromjson' "$_sops_cache" > "$_arc_dir/bookmarks.json" 2>/dev/null || true
                  chmod 600 "$_arc_dir"/*.json 2>/dev/null || true
                fi
                unset _arc_dir
              fi

              unset _sops_cache _sops_src
            fi
    ''
  );
}
