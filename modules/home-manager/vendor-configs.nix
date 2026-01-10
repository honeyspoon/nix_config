_: {
  # Vendored app configs from this repo.
  xdg.configFile = {
    "karabiner/karabiner.json".source = ../../config/karabiner/karabiner.json;

    "karabiner/assets/complex_modifications" = {
      source = ../../config/karabiner/assets/complex_modifications;
      recursive = true;
    };

    "zed/settings.json".source = ../../config/zed/settings.json;
    "zed/keymap.json".source = ../../config/zed/keymap.json;

    "neovide/config.toml".source = ../../config/neovide/config.toml;

    "httpx/config.yaml".source = ../../config/httpx/config.yaml;

    "bbot/bbot.yml".source = ../../config/bbot/bbot.yml;

    "mcphub/servers.json".source = ../../config/mcphub/servers.json;

    "amp/settings.json".source = ../../config/amp/settings.json;

    "aerospace/aerospace.toml".source = ../../config/aerospace/aerospace.toml;

    "ghostty/themes" = {
      source = ../../config/ghostty/themes;
      recursive = true;
    };

    "gh-dash/config.yml".source = ../../config/gh-dash/config.yml;

    "marimo/marimo.toml".source = ../../config/marimo/marimo.toml;

    "lazygit/config.yml".source = ../../config/lazygit/config.yml;

    "ueberzugpp/config.json".source = ../../config/ueberzugpp/config.json;
  };

  # Home-root dotfiles
  home.file.".markdownlint.json".source = ../../config/markdownlint/.markdownlint.json;
  home.file.".markdownlint.jsonc".source = ../../config/markdownlint/.markdownlint.jsonc;
}
