# Zen Browser configuration
# Migrated from Arc browser - see ~/.local/share/arc-export/ for source data
# Docs: https://github.com/0xc000022070/zen-browser-flake
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  inherit (pkgs.stdenv) isDarwin;
in {
  programs.zen-browser = {
    enable = true;

    # Required for macOS only
    darwinDefaultsId = lib.mkIf isDarwin "io.github.nicotine17.nicotine17";

    # Browser-wide policies
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    # Main profile (equivalent to Arc's "nascent" space)
    profiles.default = {
      isDefault = true;
      name = "default";

      # Spaces (workspaces) - migrated from Arc
      # Close browser before rebuilding if you change these
      spacesForce = true;
      spaces = {
        # Arc "nascent" space → default workspace
        "Personal" = {
          id = "3938d1f2-c666-4f5b-92ff-8b2807e67abe";
          position = 1000;
          theme = {
            type = "gradient";
            opacity = 0.5;
          };
        };
        # Arc "gpu" space
        "GPU" = {
          id = "7cdc7c9f-6ab5-450c-8ab9-ba4c1477e557";
          position = 2000;
          container = 1; # Firefox container for isolation
          theme = {
            type = "gradient";
            opacity = 0.5;
          };
        };
        # Arc "void *" space
        "Work" = {
          id = "7d6ccb69-4c62-4669-9e1a-23e5c1706a9f";
          position = 3000;
          container = 2;
          theme = {
            type = "gradient";
            opacity = 0.5;
          };
        };
      };

      # Search engines
      search = {
        force = true;
        default = "ddg"; # Use id, not name
        engines = {
          "Nix Packages" = {
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            definedAliases = ["@np"];
          };
          "NixOS Options" = {
            urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
            definedAliases = ["@no"];
          };
          "Home Manager Options" = {
            urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
            definedAliases = ["@hm"];
          };
          "GitHub" = {
            urls = [{template = "https://github.com/search?q={searchTerms}&type=code";}];
            definedAliases = ["@gh"];
          };
        };
      };

      # Bookmarks toolbar
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Dev";
            toolbar = true;
            bookmarks = [
              {
                name = "GitHub";
                url = "https://github.com";
              }
              {
                name = "Claude";
                url = "https://claude.ai";
              }
              {
                name = "Nix Search";
                url = "https://search.nixos.org";
              }
            ];
          }
        ];
      };

      # Extensions migrated from Arc browser
      # Run: ~/nix-config/scripts/extract-arc-data.sh to see full Arc extension list
      extensions.packages = with addons; [
        # Ad blocking & Privacy (from Arc)
        ublock-origin # was: cjpalhdlnbpafiamejdnhcphjbkeiagm
        darkreader # was: eimadpbcbfnmbkopoojfekhnkhdbieeh
        privacy-badger
        decentraleyes
        clearurls

        # Navigation (from Arc)
        vimium # was: dbepggeogbaibhgnhhndojpepiihcmeb

        # Password manager (using bitwarden instead of 1password)
        bitwarden # Arc had: 1password (aeblfdkhhhdcdjpifhhbdiojplfjncoa)

        # Development tools (from Arc)
        react-devtools # was: fmkadmapgofadopljbjfkapdkoienihi
        reduxdevtools # was: lmhkpmbekcpmknklioeibfkpmmfibljd
        refined-github # was: hlepfoohegkhhmjieoechaddaejaokhf
        # wappalyzer removed - unfree license, install manually if needed

        # Media & utility
        sponsorblock
        videospeed # Arc had: Super Video Speed Controller

        # Containers for multi-profile workflow
        multi-account-containers
      ];

      # Note: Some Arc extensions don't have Firefox equivalents:
      # - JSON Formatter: Use built-in (devtools.jsonview.enabled)
      # - Bypass Paywalls Clean: Install manually from GitHub
      # - 4chan X: Install from https://www.4chan-x.net/

      settings = {
        # Auto-enable nix-managed extensions
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;

        # Privacy
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

        # UI
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.urlbar.suggest.searches" = true;

        # Dev tools
        "devtools.theme" = "dark";
        "devtools.jsonview.enabled" = true;

        # Video/PiP
        "media.videocontrols.picture-in-picture.enabled" = true;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
      };
    };
  };
}
