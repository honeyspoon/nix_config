{
  lib,
  pkgs,
  ...
}: {
  # Home Manager activation runs with a minimal PATH on macOS.
  # Some activation steps (notably setupLaunchAgents) call `readlink -m`, which
  # macOS /usr/bin/readlink does not support. Ensure GNU coreutils are available.
  home.activation.ensureGnuTools = lib.hm.dag.entryBefore ["setupLaunchAgents"] ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.findutils}/bin:$PATH"
  '';
}
