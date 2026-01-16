{
  config,
  lib,
  ...
}: {
  programs.zsh = {
    history = {
      size = 1000000000;
      save = 1000000000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = false;
      extended = true;
      append = true;
      expireDuplicatesFirst = true;
    };

    initContent = lib.mkAfter ''
      # Write each command to the history file immediately.
      setopt INC_APPEND_HISTORY
      setopt HIST_FCNTL_LOCK

      # Keep session-local history; don't import other sessions live.
      setopt NO_SHARE_HISTORY

      # Reduce noise in the history file.
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_REDUCE_BLANKS
    '';
  };
}
