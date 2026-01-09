{lib, ...}: {
  # Ensure old compiled zshrc does not shadow Home Manager's ~/.zshrc.
  home.activation.removeZshrcZwc = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -e "$HOME/.zshrc.zwc" ] && [ ! -L "$HOME/.zshrc.zwc" ]; then
      rm -f "$HOME/.zshrc.zwc" "$HOME/.zshrc.zwc.old" 2>/dev/null || true
    fi
  '';
}
