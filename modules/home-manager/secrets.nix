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

        unset -f _load_sops_secret
      fi
    ''
  );
}
