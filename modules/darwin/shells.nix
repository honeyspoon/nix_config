{pkgs, ...}: {
  # Keep shell configuration user-scoped (Home Manager).
  # nix-darwin `programs.{zsh,bash}.enable` generates /etc/{zshrc,bashrc}.
  programs = {
    zsh.enable = false;
    bash.enable = false;
    fish.enable = true;
  };

  # Ensure these shells are valid login shells.
  environment.shells = [
    "/bin/zsh"
    "/bin/bash"
    pkgs.fish
  ];
}
