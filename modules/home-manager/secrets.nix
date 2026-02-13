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
  envJsonFile = "${cacheDir}/env.json";
  envShFile = "${cacheDir}/env.sh";
  arcExportDir = "${user.home}/.local/share/arc-export-decrypted";
in {
  # Keep the decrypted cache up-to-date during `home-manager switch` so shells and
  # MCP wrappers don't need to run sops on every startup.
  home.activation.refreshSopsSecretsCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail

    if [ -r "${secretsPath}" ] && [ -r "${ageKeyFile}" ]; then
      cache_dir="${cacheDir}"
      cache_file="${cacheFile}"

      mkdir -p "$cache_dir"
      chmod 700 "$cache_dir" 2>/dev/null || true

      old_umask="$(umask)"
      umask 077
      tmp_cache="$cache_dir/decrypted.json.tmp.$$"
      if ${pkgs.sops}/bin/sops -d --output-type json "${secretsPath}" > "$tmp_cache" 2>/dev/null; then
        if [ -s "$tmp_cache" ]; then
          mv -f "$tmp_cache" "$cache_file"
          chmod 600 "$cache_file" 2>/dev/null || true
        else
          rm -f "$tmp_cache" 2>/dev/null || true
        fi
      else
        rm -f "$tmp_cache" 2>/dev/null || true
      fi
      umask "$old_umask" 2>/dev/null || true
    fi
  '';

  # Materialize selected secrets into shell-friendly env files.
  # - env.json: machine-readable mapping used by Fish init.
  # - env.sh: POSIX-compatible exports (sourced by bash/zsh).
  home.activation.writeSopsSecretsEnv = lib.hm.dag.entryAfter ["refreshSopsSecretsCache"] ''
    set -euo pipefail

    cache_dir="${cacheDir}"
    cache_file="${cacheFile}"
    env_json="${envJsonFile}"
    env_sh="${envShFile}"

    if [ -r "$cache_file" ]; then
      mkdir -p "$cache_dir"
      chmod 700 "$cache_dir" 2>/dev/null || true

      old_umask="$(umask)"
      umask 077

      tmp_json="$cache_dir/env.json.tmp.$$"
      tmp_sh="$cache_dir/env.sh.tmp.$$"

      # Build env.json from:
      # - optional `.env` object in secrets (generic mapping)
      # - known keys we rely on in tooling (OpenAI/Datadog/Anthropic gateway)
      ${pkgs.jq}/bin/jq -c '
        def valid_name: test("^[A-Za-z_][A-Za-z0-9_]*$");
        def safe_env:
          (.env // {})
          | to_entries
          | map(select(.key | valid_name))
          | map({ (.key): (.value | tostring) })
          | add // {};
        def put(k; v):
          if (v | tostring) == "" then {} else { (k): (v | tostring) } end;

        (safe_env)
        + put("OPENAI_API_KEY"; .openai_api_key // "")
        + put("ANTHROPIC_API_KEY"; .anthropic_api_key // "")
        + put("GROQ_API_KEY"; .groq_api_key // "")
        + put("DATADOG_API_KEY"; .datadog_api_key // "")
        + put("DATADOG_APP_KEY"; .datadog_app_key // "")
        + put("DD_SITE"; (.datadog_site // "datadoghq.com"))
        + (if (.ai_gateway_api_key // "") != "" then
             {"ANTHROPIC_CUSTOM_HEADERS": "x-ai-gateway-api-key: Bearer " + (.ai_gateway_api_key | tostring)}
           else {} end)
      ' "$cache_file" > "$tmp_json" 2>/dev/null || true

      if [ -s "$tmp_json" ]; then
        mv -f "$tmp_json" "$env_json"
        chmod 600 "$env_json" 2>/dev/null || true
      else
        rm -f "$tmp_json" 2>/dev/null || true
      fi

      # Build env.sh from env.json. Only sets variables if they are not already set.
      {
        printf '%s\n' '# Auto-generated from sops cache. Do not edit.'
        printf '%s\n' '# Source: ${cacheFile}'
        printf '\n'
        ${pkgs.jq}/bin/jq -r '
          def valid_name: test("^[A-Za-z_][A-Za-z0-9_]*$");
          to_entries[]
          | select(.key | valid_name)
          | "if [ -z \"$(printenv " + .key + " 2>/dev/null)\" ]; then export " + .key + "=" + (.value | tostring | @sh) + "; fi"
        ' "$env_json" 2>/dev/null || true
      } > "$tmp_sh"

      if [ -s "$tmp_sh" ]; then
        mv -f "$tmp_sh" "$env_sh"
        chmod 600 "$env_sh" 2>/dev/null || true
      else
        rm -f "$tmp_sh" 2>/dev/null || true
      fi

      umask "$old_umask" 2>/dev/null || true
    fi
  '';

  # Ensure secrets are available in all interactive shells.
  programs = {
    bash.initExtra = lib.mkAfter ''
      if [ -r "${envShFile}" ]; then
        . "${envShFile}"
      fi
    '';

    fish.shellInit = lib.mkAfter ''
      set -l env_json "${envJsonFile}"
      if test -r "$env_json"
        for line in (${pkgs.jq}/bin/jq -r 'to_entries[] | "\(.key)=\(.value|tostring|@base64)"' "$env_json" 2>/dev/null)
          set -l key (string split -m1 '=' -- $line)[1]
          set -l b64 (string split -m1 '=' -- $line)[2]
          if test -n "$key"; and not set -q $key
            set -gx $key (printf '%s' -- "$b64" | ${pkgs.coreutils}/bin/base64 -d 2>/dev/null)
          end
        end
      end
    '';

    # Decrypt secrets directly in shell init (workaround for sops-nix launchd PATH issue on macOS)
    # Optimized: decrypt once and cache, extract all values with jq
    zsh.initContent = lib.mkIf (builtins.pathExists secretsFile) (
      lib.mkAfter ''
              # Fast-path: source precomputed env exports (generated during HM activation).
              if [ -r "${envShFile}" ]; then
                . "${envShFile}"
              fi

              # Load secrets from sops-encrypted file (cached for fast shell startup)
              if [ -r "${secretsPath}" ] && [ -r "${ageKeyFile}" ]; then
                _sops_cache="${cacheFile}"
                _sops_src="${secretsPath}"

                # Regenerate cache if secrets file is newer or cache doesn't exist
                if [ ! -f "$_sops_cache" ] || [ "$_sops_src" -nt "$_sops_cache" ]; then
                  mkdir -p "${cacheDir}"
                  chmod 700 "${cacheDir}" 2>/dev/null || true
                  _old_umask="$(umask)"
                  umask 077
                  _tmp_cache="${cacheDir}/decrypted.json.tmp.$$"
                  if ${pkgs.sops}/bin/sops -d --output-type json "$_sops_src" > "$_tmp_cache" 2>/dev/null; then
                    if [ -s "$_tmp_cache" ]; then
                      mv -f "$_tmp_cache" "$_sops_cache"
                      chmod 600 "$_sops_cache" 2>/dev/null || true
                    else
                      rm -f "$_tmp_cache" 2>/dev/null || true
                    fi
                  else
                    rm -f "$_tmp_cache" 2>/dev/null || true
                  fi
                  umask "$_old_umask" 2>/dev/null || true
                  unset _tmp_cache _old_umask
                fi

                # If we refreshed the cache, refresh env files too.
                if [ -r "$_sops_cache" ] && { [ ! -r "${envJsonFile}" ] || [ "$_sops_cache" -nt "${envJsonFile}" ]; }; then
                  _old_umask="$(umask)"
                  umask 077
                  _tmp_json="${cacheDir}/env.json.tmp.$$"
                  _tmp_sh="${cacheDir}/env.sh.tmp.$$"

                  ${pkgs.jq}/bin/jq -c '
                    def valid_name: test("^[A-Za-z_][A-Za-z0-9_]*$");
                    def safe_env:
                      (.env // {})
                      | to_entries
                      | map(select(.key | valid_name))
                      | map({ (.key): (.value | tostring) })
                      | add // {};
                    def put(k; v):
                      if (v | tostring) == "" then {} else { (k): (v | tostring) } end;

                    (safe_env)
                    + put("OPENAI_API_KEY"; .openai_api_key // "")
                    + put("ANTHROPIC_API_KEY"; .anthropic_api_key // "")
                    + put("GROQ_API_KEY"; .groq_api_key // "")
                    + put("DATADOG_API_KEY"; .datadog_api_key // "")
                    + put("DATADOG_APP_KEY"; .datadog_app_key // "")
                    + put("DD_SITE"; (.datadog_site // "datadoghq.com"))
                    + (if (.ai_gateway_api_key // "") != "" then
                         {"ANTHROPIC_CUSTOM_HEADERS": "x-ai-gateway-api-key: Bearer " + (.ai_gateway_api_key | tostring)}
                       else {} end)
                  ' "$_sops_cache" > "$_tmp_json" 2>/dev/null || true

                  if [ -s "$_tmp_json" ]; then
                    mv -f "$_tmp_json" "${envJsonFile}"
                    chmod 600 "${envJsonFile}" 2>/dev/null || true

                    {
                      printf '%s\n' '# Auto-generated from sops cache. Do not edit.'
                      printf '%s\n' '# Source: ${cacheFile}'
                      printf '\n'
                      ${pkgs.jq}/bin/jq -r '
                        def valid_name: test("^[A-Za-z_][A-Za-z0-9_]*$");
                        to_entries[]
                        | select(.key | valid_name)
                        | "if [ -z \"$(printenv " + .key + " 2>/dev/null)\" ]; then export " + .key + "=" + (.value | tostring | @sh) + "; fi"
                      ' "${envJsonFile}" 2>/dev/null || true
                    } > "$_tmp_sh"

                    if [ -s "$_tmp_sh" ]; then
                      mv -f "$_tmp_sh" "${envShFile}"
                      chmod 600 "${envShFile}" 2>/dev/null || true
                    else
                      rm -f "$_tmp_sh" 2>/dev/null || true
                    fi
                  else
                    rm -f "$_tmp_json" 2>/dev/null || true
                  fi

                  umask "$_old_umask" 2>/dev/null || true
                  unset _tmp_json _tmp_sh _old_umask

                  if [ -r "${envShFile}" ]; then
                    . "${envShFile}"
                  fi
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

                  # Dogshell config
                  if { [ ! -f "$HOME/.dogrc" ] || [ "$_sops_cache" -nt "$HOME/.dogrc" ]; } \
                    && [ -n "$_datadog_api_key" ] \
                    && [ -n "$_datadog_app_key" ]; then
                    _old_umask="$(umask)"
                    umask 077
                    printf '%s\n' \
                      "[Connection]" \
                      "apikey = $_datadog_api_key" \
                      "appkey = $_datadog_app_key" \
                      "api_host = https://api.''${_datadog_site:-datadoghq.com}" \
                      > "$HOME/.dogrc"
                    chmod 600 "$HOME/.dogrc" 2>/dev/null || true
                    umask "$_old_umask" 2>/dev/null || true
                    unset _old_umask
                  fi

                  # SSH hosts config (only regenerate if cache was updated)
                  _ssh_config="$HOME/.ssh/config.d/hosts.conf"
                  if [ ! -f "$_ssh_config" ] || [ "$_sops_cache" -nt "$_ssh_config" ]; then
                    mkdir -p "$HOME/.ssh/config.d"
                    _old_umask="$(umask)"
                    umask 077
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

        # abder-dev via Tailscale (auto-starts EC2 if stopped, connects via Tailscale)
        Host abder-dev
          HostName 100.105.199.43
          User abder
          IdentityFile ~/.ssh/dev.pem
          ProxyCommand sh -c 'STATE=\$(aws ec2 describe-instances --region ca-central-1 --instance-ids $_ssh_abder_dev_instance --query "Reservations[0].Instances[0].State.Name" --output text); if [ "\$STATE" = "stopped" ]; then echo "Starting instance..." >&2; aws ec2 start-instances --region ca-central-1 --instance-ids $_ssh_abder_dev_instance >&2; aws ec2 wait instance-running --region ca-central-1 --instance-ids $_ssh_abder_dev_instance >&2; echo "Waiting for Tailscale..." >&2; sleep 20; fi; nc %h %p'

        # abder-dev via public IP (fallback if Tailscale is down)
        Host abder-dev-public
          HostName $_ssh_abder_dev_host
          User abder
          IdentityFile ~/.ssh/dev.pem
          ProxyCommand sh -c 'STATE=\$(aws ec2 describe-instances --region ca-central-1 --instance-ids $_ssh_abder_dev_instance --query "Reservations[0].Instances[0].State.Name" --output text); if [ "\$STATE" = "stopped" ]; then echo "Starting instance..." >&2; aws ec2 start-instances --region ca-central-1 --instance-ids $_ssh_abder_dev_instance >&2; aws ec2 wait instance-running --region ca-central-1 --instance-ids $_ssh_abder_dev_instance >&2; sleep 15; fi; nc %h %p'
        SSHEOF
                    chmod 600 "$_ssh_config"
                    umask "$_old_umask" 2>/dev/null || true
                    unset _old_umask
                  fi

                  # Cleanup temporary variables
                  unset _openai_api_key _ai_gateway_api_key _datadog_api_key _datadog_app_key _datadog_site
                  unset _ssh_perf_bench_host _ssh_zuck_test_host _ssh_gpu_test_host
                  unset _ssh_abder_dev_host _ssh_abder_dev_instance _ssh_ssm_instance _ssh_config

                  # Export Arc browser data from sops (for Zen browser import)
                  _arc_dir="${arcExportDir}"
                  if [ ! -d "$_arc_dir" ] || [ "$_sops_cache" -nt "$_arc_dir/tabs.json" ]; then
                    mkdir -p "$_arc_dir"
                    chmod 700 "$_arc_dir" 2>/dev/null || true
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
  };
}
