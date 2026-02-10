{
  pkgs,
  user,
  ...
}: {
  nix = {
    enable = true;
    package = pkgs.nix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Less noise for flake commands while iterating.
      warn-dirty = false;

      # Prefer prebuilt binaries when available.
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"

        # Determinate Systems public cache (helps avoid local builds for some things)
        "https://install.determinate.systems"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

        # Used by Determinate's cache; safe to add even without Determinate Nix installed
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];

      max-jobs = 8;
      cores = 0;

      trusted-users = [
        "@admin"
        user.name
      ];
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    # Replacement for `nix.settings.auto-optimise-store`
    optimise.automatic = true;
  };
}
