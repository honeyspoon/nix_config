_: {
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Required by newer nix-darwin: activation runs as root and
  # user-scoped options attach to this primary user.
  system.primaryUser = "abder";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
