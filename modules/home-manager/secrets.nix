{
  config,
  lib,
  user,
  ...
}: let
  secretsFile = ../../secrets/secrets.yaml;
in {
  # Enable sops-nix only when you add an encrypted secrets file.
  # This keeps the flake usable for new machines/clones.
  sops = lib.mkIf (builtins.pathExists secretsFile) {
    defaultSopsFile = secretsFile;

    # Recommended: manage the age key locally (not in git).
    # A common choice is to use age-plugin-ssh and a key derived from your SSH key.
    age.keyFile = "${user.home}/.config/sops/age/keys.txt";

    secrets = {
      openai_api_key = {};
    };
  };

  # Optional: load secrets into interactive shells at runtime.
  # This avoids baking secret values into the Nix store.
  programs.zsh.initExtra = lib.mkIf (builtins.pathExists secretsFile) (
    lib.mkAfter ''
      secret_path="${config.sops.secrets.openai_api_key.path}"
      if [ -z "''${OPENAI_API_KEY:-}" ] && [ -r "$secret_path" ]; then
        export OPENAI_API_KEY="$(cat \"$secret_path\")"
      fi
    ''
  );
}
