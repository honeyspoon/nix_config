_: {
  # Rift config lives in this repo under `config/rift/`.
  xdg.configFile."rift/config.toml" = {
    source = ../../config/rift/config.toml;
  };

  # Some installs also use a top-level config file.
  home.file.".rift.toml".source = ../../config/rift/rift.toml;
}
