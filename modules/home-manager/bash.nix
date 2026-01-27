{config, ...}: {
  programs.bash = {
    enable = true;
    inherit (config.programs.zsh) shellAliases;

    initExtra = ''
      # Fix ghostty TERM on Linux when terminfo is missing
      if [[ "$TERM" == ghostty* || "$TERM" == xterm-ghostty* ]] && ! infocmp "$TERM" &>/dev/null 2>&1; then
        export TERM=xterm-256color
      fi
    '';
  };
}
