{pkgs, ...}: {
  nix = {
    enable = true;
    package = pkgs.nix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = 8;
      cores = 0;

      trusted-users = [
        "@admin"
        "abder"
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
