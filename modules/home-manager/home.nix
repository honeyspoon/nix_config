# Main home-manager entry point
# Platform-specific modules are handled via lib.mkIf in each module
{...}: {
  imports = [
    ./core.nix
    ./packages.nix
    ./programs.nix

    ./shell.nix
    ./git.nix
    ./neovim.nix
    ./claude.nix
    ./opencode.nix
    ./rift.nix
    ./terminal.nix
    ./zen-browser.nix
    ./skills.nix
    ./vendor-configs.nix
    ./ssh.nix
    ./cronjobs.nix
    ./lspmux.nix

    ./activation-tools.nix

    # macOS-specific modules (uses lib.mkIf inside)
    ./darwin
  ];
}
