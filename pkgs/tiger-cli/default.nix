{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "tiger-cli";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "timescale";
    repo = "tiger-cli";
    rev = "v${version}";
    hash = "sha256-HSu4DhUyeJ1WV6ezBX/3ACRkE8/29BbXiVcrVTXDNZc=";
  };

  vendorHash = "sha256-C81qk5E802wWsGa/FJcmpjSUokCfoVg2/f2tG4TYTCE=";

  subPackages = ["cmd/tiger"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/timescale/tiger-cli/internal/config.Version=${version}"
  ];

  meta = {
    description = "CLI for Tiger Cloud (TimescaleDB) with integrated MCP server";
    homepage = "https://github.com/timescale/tiger-cli";
    license = lib.licenses.asl20;
    mainProgram = "tiger";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
}
