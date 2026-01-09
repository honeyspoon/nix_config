_: {
  users.users.abder = {
    name = "abder";
    home = "/Users/abder";

    # Use the system zsh so nix-darwin doesn't need to manage /etc/zshrc.
    shell = "/bin/zsh";
  };
}
