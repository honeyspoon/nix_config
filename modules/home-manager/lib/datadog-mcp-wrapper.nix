{pkgs}:
pkgs.writeShellScript "datadog-mcp-wrapper" ''
  set -u

  CACHE_DIR="$HOME/.cache/sops-secrets"
  CACHE_FILE="$CACHE_DIR/decrypted.json"
  SECRETS_FILE="$HOME/nix-config/secrets/secrets.yaml"
  AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

  maybe_refresh_cache() {
    if [ -r "$SECRETS_FILE" ] && [ -r "$AGE_KEY_FILE" ]; then
      if [ ! -f "$CACHE_FILE" ] || [ "$SECRETS_FILE" -nt "$CACHE_FILE" ]; then
        mkdir -p "$CACHE_DIR" 2>/dev/null || true
        chmod 700 "$CACHE_DIR" 2>/dev/null || true

        old_umask="$(umask)"
        umask 077
        tmp_cache="$CACHE_DIR/decrypted.json.tmp.$$"
        if ${pkgs.sops}/bin/sops -d --output-type json "$SECRETS_FILE" > "$tmp_cache" 2>/dev/null; then
          if [ -s "$tmp_cache" ]; then
            mv -f "$tmp_cache" "$CACHE_FILE"
            chmod 600 "$CACHE_FILE" 2>/dev/null || true
          else
            rm -f "$tmp_cache" 2>/dev/null || true
          fi
        else
          rm -f "$tmp_cache" 2>/dev/null || true
        fi
        umask "$old_umask" 2>/dev/null || true
      fi
    fi
  }

  if [ -z "''${DATADOG_API_KEY:-}" ] || [ -z "''${DATADOG_APP_KEY:-}" ] || [ -z "''${DD_SITE:-}" ]; then
    maybe_refresh_cache
    if [ -r "$CACHE_FILE" ]; then
      : "''${DATADOG_API_KEY:=$(${pkgs.jq}/bin/jq -r '.datadog_api_key // empty' "$CACHE_FILE")}"
      : "''${DATADOG_APP_KEY:=$(${pkgs.jq}/bin/jq -r '.datadog_app_key // empty' "$CACHE_FILE")}"
      : "''${DD_SITE:=$(${pkgs.jq}/bin/jq -r '.datadog_site // "datadoghq.com"' "$CACHE_FILE")}"
      export DATADOG_API_KEY DATADOG_APP_KEY DD_SITE
    fi
  fi

  if [ -z "''${DATADOG_API_KEY:-}" ] || [ -z "''${DATADOG_APP_KEY:-}" ]; then
    echo "datadog-mcp-wrapper: missing DATADOG_API_KEY/DATADOG_APP_KEY (sops cache not available)" >&2
  fi

  exec ${pkgs.nodejs_24}/bin/npx -y @winor30/mcp-server-datadog "$@"
''
