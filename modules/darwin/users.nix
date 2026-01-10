{user, ...}: {
  users.users.${user.name} = {
    inherit (user) name home;

    # Use the system zsh so nix-darwin doesn't need to manage /etc/zshrc.
    shell = "/bin/zsh";
  };
}
