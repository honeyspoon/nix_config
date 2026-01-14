{
  pkgs,
  inputs,
  ...
}: let
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.zen-browser = {
    enable = true;

    # Required for macOS
    darwinDefaultsId = "io.github.nicotine17.nicotine17";

    profiles.default = {
      isDefault = true;
      name = "default";

      # Declarative extensions
      extensions.packages = with addons; [
        ublock-origin
        bitwarden
        darkreader
        vimium
        sponsorblock
        privacy-badger
        decentraleyes
        clearurls
        multi-account-containers
      ];

      settings = {
        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.send_pings" = false;
        "dom.battery.enabled" = false;

        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # UI preferences
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.urlbar.suggest.searches" = true;
        "browser.urlbar.showSearchSuggestionsFirst" = false;

        # Developer tools
        "devtools.theme" = "dark";
      };
    };
  };
}
