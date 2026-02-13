{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  fetchFromGitHub,
  rustPlatform,
}: let
  pname = "gdrive";
  version = "3.9.1";

  isX86_64 = stdenv.hostPlatform.isx86_64;

  prebuilt =
    if isX86_64 && stdenv.isLinux
    then {
      url = "https://github.com/glotlabs/gdrive/releases/download/${version}/gdrive_linux-x64.tar.gz";
      hash = "sha256-Bkbvoe0VphUe9eGk9yOCXIGTVZGtegHoZoWvqBOLx8k=";
    }
    else if isX86_64 && stdenv.isDarwin
    then {
      url = "https://github.com/glotlabs/gdrive/releases/download/${version}/gdrive_macos-x64.tar.gz";
      hash = "sha256-SeAJ79SMJ1TDm9mdfXCp4A4lcbHzckAOx1n8v4dgAmk=";
    }
    else null;
in
  if prebuilt != null
  then
    stdenvNoCC.mkDerivation {
      inherit pname version;

      src = fetchurl {
        inherit (prebuilt) url hash;
      };

      nativeBuildInputs = lib.optionals stdenv.isLinux [
        autoPatchelfHook
      ];

      dontConfigure = true;
      dontBuild = true;

      unpackPhase = ''
        runHook preUnpack
        tar -xzf "$src"
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/bin"
        bin_path="$(find . -maxdepth 2 -type f -name gdrive -print -quit)"
        if [ -z "$bin_path" ]; then
          echo "gdrive: could not locate 'gdrive' in archive" >&2
          exit 1
        fi
        install -m755 "$bin_path" "$out/bin/gdrive"

        runHook postInstall
      '';

      meta = {
        description = "Command-line tool for Google Drive";
        homepage = "https://github.com/glotlabs/gdrive";
        license = lib.licenses.mit;
        mainProgram = "gdrive";
        platforms = [
          "x86_64-linux"
          "x86_64-darwin"
        ];
        sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      };
    }
  else
    rustPlatform.buildRustPackage rec {
      inherit pname version;

      src = fetchFromGitHub {
        owner = "glotlabs";
        repo = "gdrive";
        rev = version;
        hash = "sha256-1yJg+rEhKTGXC7mlHxnWGUuAm9/RwhD6/Xg/GBKyQMw=";
      };

      cargoHash = "sha256-ZIswHJBV1uwrnSm5BmQgb8tVD1XQMTQXQ5DWvBj1WDk=";

      meta = {
        description = "Command-line tool for Google Drive";
        homepage = "https://github.com/glotlabs/gdrive";
        license = lib.licenses.mit;
        mainProgram = "gdrive";
        platforms = lib.platforms.unix;
      };
    }
