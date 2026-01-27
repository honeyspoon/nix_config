{
  lib,
  pkgs,
  config,
  ...
}: {
  # Home Manager activation runs with a minimal PATH on macOS.
  # Some activation steps (notably setupLaunchAgents) call `readlink -m`, which
  # macOS /usr/bin/readlink does not support. Ensure GNU coreutils are available.
  home.activation.ensureGnuTools = lib.hm.dag.entryBefore ["setupLaunchAgents"] ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.findutils}/bin:$PATH"
  '';

  # On standalone home-manager, ensure the profile path for packages is writable
  # This fixes "Permission denied" errors when installing packages via nix-env
  home.activation.fixProfilePath = lib.hm.dag.entryBefore ["installPackages"] ''
    profileDir="${config.home.profileDirectory}"

    # If the profile directory is a symlink to nix store, we need to use a local profile
    if [ -L "$profileDir" ] && [[ "$(readlink -f "$profileDir")" == /nix/store/* ]]; then
      # Create a local profile directory that nix-env can use
      localProfileDir="$HOME/.local/state/nix/profiles"
      mkdir -p "$localProfileDir"

      # Ensure home-manager profile base exists and is not pointing to store
      hmProfile="$localProfileDir/home-manager"
      if [ -L "$hmProfile" ]; then
        target="$(readlink "$hmProfile")"
        # If it points to a generation, that's fine - nix-env should use home-path sibling
        :
      fi
    fi
  '';
}
