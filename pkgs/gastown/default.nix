{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "gastown";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "gastown";
    rev = "v${version}";
    hash = "sha256-mtouqawxbaLruvBNuXSyYCwREEg1mi0SFQRLfOdJQxI=";
  };

  # Let Nix fetch Go modules (no vendor directory in repo)
  vendorHash = "sha256-ripY9vrYgVW8bngAyMLh0LkU/Xx1UUaLgmAA7/EmWQU=";

  subPackages = ["cmd/gt"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Gas Town - multi-agent workspace manager by Steve Yegge";
    homepage = "https://github.com/steveyegge/gastown";
    license = lib.licenses.asl20;
    mainProgram = "gt";
    platforms = lib.platforms.unix;
  };
}
