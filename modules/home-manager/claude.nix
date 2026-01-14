_: let
  claudeSettings = {
    defaultMode = "bypassPermissions";
  };
in {
  home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
}
