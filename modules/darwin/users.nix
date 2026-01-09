{pkgs, ...}: {
  users.users.abder = {
    name = "abder";
    home = "/Users/abder";
    shell = pkgs.zsh;
  };
}
