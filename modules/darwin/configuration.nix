# Main nix-darwin configuration entry point
{...}: {
  imports = [
    ./base.nix
    ./packages.nix
    ./nix.nix
    ./shells.nix
    ./macos-defaults.nix
    ./security.nix
    ./users.nix
    ./fonts.nix
    ./homebrew.nix
    ./cronjobs.nix
  ];
}
