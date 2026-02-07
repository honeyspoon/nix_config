# Main home-manager entry point
# Platform-specific modules are handled via lib.mkIf in each module
#
# Module hierarchy (inspired by jonhoo/configs):
#   Base    — core identity, shell, git, packages (minimal working env)
#   Dev     — editors, AI tools, LSP, languages, devops
#   Personal— browser, terminal theming, SSH, cron, macOS tweaks
#
# To create a minimal profile, import only the base layer.
{...}: {
  imports = [
    # ── Base layer: minimal shell environment ──────────────────────────
    ./core.nix
    ./packages.nix
    ./programs.nix
    ./shell.nix
    ./git.nix

    # ── Dev layer: editors, AI, LSP ───────────────────────────────────
    ./neovim.nix
    ./claude.nix
    ./opencode.nix
    ./rift.nix
    ./lspmux.nix
    ./skills.nix

    # ── Personal layer: browser, terminal, theming, macOS ─────────────
    ./stylix.nix
    ./terminal.nix
    ./zen-browser.nix
    ./vendor-configs.nix
    ./ssh.nix
    ./cronjobs.nix
    ./activation-tools.nix

    # macOS-specific modules (uses lib.mkIf inside)
    ./darwin
  ];
}
