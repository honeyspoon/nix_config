_: {
  xdg.configFile."ghostty/config".text = ''
    # Make terminal bells noticeable when Ghostty is unfocused.
    # - attention: bounce dock icon
    # - title: show a 🔔 in the title
    bell-features = attention,title
  '';
}
