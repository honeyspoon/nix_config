{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}: let
  pname = "agentfs";
  version = "0.6.0";

  inherit (stdenv.hostPlatform) system;

  srcTable = {
    "aarch64-darwin" = {
      url = "https://github.com/tursodatabase/agentfs/releases/download/v${version}/agentfs-aarch64-apple-darwin.tar.xz";
      hash = "sha256-4IA2Xgic4XmIAPtK3pH4Y6Y1s4G+PNoYRs/3LP6bkD8=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/tursodatabase/agentfs/releases/download/v${version}/agentfs-x86_64-apple-darwin.tar.xz";
      hash = "sha256-2lHSev5t+vEmdDhso7kJ1b4j4OUkNMeD4FP2JJ8ZqKk=";
    };
    "aarch64-linux" = {
      url = "https://github.com/tursodatabase/agentfs/releases/download/v${version}/agentfs-aarch64-unknown-linux-gnu.tar.xz";
      hash = "sha256-UN8YOVINy2BwHC4ucsG4U/na7Z4MCsiQ9hAcj7Zw6cY=";
    };
    "x86_64-linux" = {
      url = "https://github.com/tursodatabase/agentfs/releases/download/v${version}/agentfs-x86_64-unknown-linux-gnu.tar.xz";
      hash = "sha256-cDdzJKyBn541QduCq2XOT/BOOFuWE3y1qZwTlPAKvcQ=";
    };
  };

  srcInfo = srcTable.${system} or (throw "agentfs: unsupported system ${system}");

  src = fetchurl {
    inherit (srcInfo) url hash;
  };
in
  stdenvNoCC.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      tar -xJf "$src"
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      bin_path="$(find . -maxdepth 2 -type f -name agentfs -print -quit)"
      if [ -z "$bin_path" ]; then
        echo "agentfs: could not locate 'agentfs' in archive" >&2
        exit 1
      fi
      install -m755 "$bin_path" "$out/bin/agentfs"

      runHook postInstall
    '';

    meta = {
      description = "Filesystem for agents backed by SQLite";
      homepage = "https://github.com/tursodatabase/agentfs";
      license = lib.licenses.mit;
      mainProgram = "agentfs";
      platforms = builtins.attrNames srcTable;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
