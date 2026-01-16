{
  lib,
  stdenv,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs,
  makeWrapper,
  rustPlatform,
  inputs,
}: let
  version = "0.5.0";

  src = inputs.agent-browser;

  pnpmDeps = fetchPnpmDeps {
    pname = "agent-browser";
    inherit version src;

    # Keep in sync with nixpkgs docs; 3 is current stable.
    fetcherVersion = 3;

    hash = "sha256-D/X7Z1o/cQ23/1wXixscBkIL4Kah4lIK+5/fGFqYDpo=";
  };

  daemon = stdenv.mkDerivation {
    pname = "agent-browser-daemon";
    inherit version src pnpmDeps;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    # Avoid upstream postinstall attempting network downloads.
    pnpmInstallFlags = [
      "--ignore-scripts"
    ];

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      # Runtime JS (daemon) + runtime deps.
      cp -R dist $out/dist
      cp -R node_modules $out/node_modules

      runHook postInstall
    '';
  };

  cli = rustPlatform.buildRustPackage {
    pname = "agent-browser";
    inherit version src;

    sourceRoot = "source/cli";

    cargoLock = {
      lockFile = "${src}/cli/Cargo.lock";
    };

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/dist

      cp -R ${daemon}/dist $out/dist
      # node module tree can be large; keep it adjacent to dist.
      cp -R ${daemon}/node_modules $out/node_modules

      # Install the Rust CLI.
      cp target/*/release/agent-browser $out/bin/agent-browser

      # Ensure node is available at runtime and default to nixpkgs Chromium.
      wrapProgram $out/bin/agent-browser \
        --prefix PATH : ${lib.makeBinPath [nodejs]} \
        --set-default AGENT_BROWSER_HOME $out

      runHook postInstall
    '';

    meta = {
      description = "Headless browser automation CLI for AI agents";
      homepage = "https://agent-browser.dev";
      license = lib.licenses.asl20;
      mainProgram = "agent-browser";
      platforms = lib.platforms.darwin ++ lib.platforms.linux;
    };
  };
in
  cli
