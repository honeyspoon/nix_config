# macOS system defaults (dock, finder, keyboard, trackpad, etc.)
_: {
  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
        minimize-to-application = true;

        show-process-indicators = true;
        "autohide-delay" = 0.0;
        "autohide-time-modifier" = 0.2;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXSortFoldersFirst = true;
      };

      NSGlobalDomain = {
        KeyRepeat = 2;
        InitialKeyRepeat = 15;

        NSAutomaticSpellingCorrectionEnabled = false;

        AppleKeyboardUIMode = 3;

        # Key repeat instead of press-and-hold.
        ApplePressAndHoldEnabled = false;

        # Save to disk by default (not iCloud).
        NSDocumentSaveNewDocumentsToCloud = false;

        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;

        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };

      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
        disable-shadow = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
