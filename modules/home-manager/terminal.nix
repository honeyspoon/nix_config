_: {
  xdg.configFile."ghostty/config".text = ''
    # theme = cyberdream
    theme = tokyonight

    shell-integration = zsh
    window-save-state = always

    window-colorspace = display-p3
    bold-is-bright = true
    font-thicken = true

    keybind = performable:ctrl+h=goto_split:left
    keybind = performable:ctrl+j=goto_split:down
    keybind = performable:ctrl+k=goto_split:up
    keybind = performable:ctrl+l=goto_split:right

    keybind = performable:ctrl+shift+h=resize_split:left,10
    keybind = performable:ctrl+shift+j=resize_split:down,10
    keybind = performable:ctrl+shift+k=resize_split:up,10
    keybind = performable:ctrl+shift+l=resize_split:right,14

    # keybind = ctrl+shift+h=esc:[72;6u
    # keybind = ctrl+shift+j=esc:[74;6u
    # keybind = ctrl+shift+k=esc:[77;6u
    # keybind = ctrl+shift+l=esc:[76;6u

    keybind = ctrl+a>z=toggle_split_zoom

    keybind = ctrl+a>shift+backslash=new_split:right
    keybind = ctrl+a>shift+apostrophe=new_split:down

    keybind = ctrl+a>ctrl+l=clear_screen

    unfocused-split-opacity=0.9
  '';
}
