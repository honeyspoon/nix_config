{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:
buildGoModule rec {
  pname = "beads";
  version = "0.44.0";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-usK4iFG9BvceL1Hdqzmt227O8fvLqAf6VSQe5QpRCKc=";
  };

  vendorHash = "sha256-BpACCjVk0V5oQ5YyZRv9wC/RfHw4iikc2yrejZzD1YU=";

  nativeCheckInputs = [git];

  # Tests require git worktree setup that's complex in sandbox
  doCheck = false;

  subPackages = ["cmd/bd"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Beads - lightweight memory system for AI coding agents";
    homepage = "https://github.com/steveyegge/beads";
    license = lib.licenses.asl20;
    mainProgram = "bd";
    platforms = lib.platforms.unix;
  };
}
