{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
}: let
  version = "0.20.0";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/timescale/tiger-cli/releases/download/v${version}/tiger-cli_Darwin_arm64.tar.gz";
      hash = "sha256-MQY7wLWvCrZ9D0PXtg+OpVr7TB2nH+FgEFwgQd/Ghgg=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/timescale/tiger-cli/releases/download/v${version}/tiger-cli_Darwin_x86_64.tar.gz";
      hash = "sha256-tEdU+4yLgtVMbMBYs1NNpLiFUuv4NFw8JHOqULPimag=";
    };
    "aarch64-linux" = {
      url = "https://github.com/timescale/tiger-cli/releases/download/v${version}/tiger-cli_Linux_arm64.tar.gz";
      hash = "sha256-CYqNfiFLkoPK6vJ72poRPYArzXELpD93ByZsl5K2i2c=";
    };
    "x86_64-linux" = {
      url = "https://github.com/timescale/tiger-cli/releases/download/v${version}/tiger-cli_Linux_x86_64.tar.gz";
      hash = "sha256-DBjLQ5p5VFDD8tPAdSdKKX/BYWtLiIHf8wtZz9BlHiY=";
    };
  };

  src = fetchurl sources.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation {
    pname = "tiger-cli";
    inherit version src;

    sourceRoot = ".";

    nativeBuildInputs =
      [installShellFiles]
      ++ lib.optionals stdenv.isLinux [autoPatchelfHook];

    installPhase = ''
      runHook preInstall

      install -Dm755 tiger $out/bin/tiger

      runHook postInstall
    '';

    meta = {
      description = "CLI for Tiger Cloud (TimescaleDB) with integrated MCP server";
      homepage = "https://github.com/timescale/tiger-cli";
      license = lib.licenses.asl20;
      mainProgram = "tiger";
      platforms = ["aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
