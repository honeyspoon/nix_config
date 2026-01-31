{
  description = "Abder's Nix Configuration (macOS + Linux)";

  inputs = {
    # Use darwin branch for compatibility with nix-darwin
    # This also works fine on Linux
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agent skills (auto-update with `nix flake update`)
    skill-react-best-practices = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };

    agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };

    # OpenCode plugins
    opencode-notify = {
      url = "github:kdcokenny/opencode-notify";
      flake = false;
    };

    opencode-mystatus = {
      url = "github:vbgate/opencode-mystatus";
      flake = false;
    };

    # Rust toolchain
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit hooks (native Nix integration)
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Treefmt for unified formatting
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    sops-nix,
    nix-index-database,
    zen-browser,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = let
        # User config - shared across platforms
        mkUser = system: let
          isDarwin = builtins.match ".*-darwin" system != null;
        in {
          name = "abder";
          home =
            if isDarwin
            then "/Users/abder"
            else "/home/abder";
        };

        # Shared home-manager modules
        sharedHmModules = [
          sops-nix.homeManagerModules.sops
          nix-index-database.homeModules.nix-index
          zen-browser.homeModules.twilight
          ./modules/home-manager/secrets.nix
        ];

        # Darwin host
        darwinHost = "workmbp";
      in {
        # macOS: Build darwin flake using:
        # $ darwin-rebuild build --flake .#workmbp
        darwinConfigurations.${darwinHost} = let
          system = "aarch64-darwin";
          user = mkUser system;
          host = darwinHost;
        in
          nix-darwin.lib.darwinSystem {
            specialArgs = {inherit user host;};
            inherit system;
            modules = [
              ./modules/darwin/configuration.nix

              # Expose wrapped apps and rust toolchain as pkgs.* within nix-darwin
              {nixpkgs.overlays = [inputs.rust-overlay.overlays.default self.overlays.default];}

              # Home Manager module
              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;

                  # Back up pre-existing dotfiles once so the first `darwin-switch` succeeds.
                  backupFileExtension = "before-nix-home-manager";

                  extraSpecialArgs = {inherit user host inputs;};
                  sharedModules = sharedHmModules;
                  users.${user.name} = import ./modules/home-manager/home.nix;
                };
              }
            ];
          };

        # Linux: Standalone home-manager configurations
        # Apply with: home-manager switch --flake .#abder@linux
        homeConfigurations = let
          mkHomeConfig = system: let
            user = mkUser system;
            host = "linux";
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                inputs.rust-overlay.overlays.default
                self.overlays.default
              ];
            };
          in
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {inherit user host inputs;};
              modules =
                sharedHmModules
                ++ [
                  ./modules/home-manager/home.nix
                ];
            };
        in {
          "abder@linux" = mkHomeConfig "x86_64-linux";
          "abder@linux-arm" = mkHomeConfig "aarch64-linux";
        };

        overlays.default = _final: prev: {
          inherit
            (self.packages.${prev.stdenv.hostPlatform.system})
            agent-browser
            nvim-lazyvim
            ;
        };
      };

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        # Native Nix pre-commit hooks (replaces pre-commit-config.yaml)
        preCommitHooks = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Nix
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;

            # Lua
            stylua.enable = true;

            # TOML
            taplo.enable = true;

            # General
            prettier = {
              enable = true;
              excludes = ["flake.lock" "*.nix"];
            };

            # Security
            gitleaks = {
              enable = true;
              entry = "${pkgs.gitleaks}/bin/gitleaks detect --source . --no-git --redact --config .gitleaks.toml";
            };
          };
        };

        # Treefmt configuration (unified formatter)
        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true; # Nix
            stylua.enable = true; # Lua
            taplo.enable = true; # TOML
            prettier.enable = true; # JS/JSON/MD/YAML
          };
        };

        host = "workmbp";
        isDarwin = builtins.match ".*-darwin" system != null;
        darwinRebuild = "${nix-darwin.packages.${system}.default}/bin/darwin-rebuild";

        # Evaluate the full nix-darwin configuration during `nix flake check`
        # so module/option errors surface early, without forcing a full build.
        darwinEval =
          if isDarwin
          then
            pkgs.runCommand "darwin-eval" {} (
              builtins.seq self.darwinConfigurations.${host}.system ''
                echo ok > $out
              ''
            )
          else pkgs.runCommand "darwin-eval-skip" {} "echo skipped > $out";

        lazyvimConfig = pkgs.runCommand "lazyvim-config" {} ''
          mkdir -p "$out/config"
          cp -R "${./config/nvim}" "$out/config/nvim"
        '';
      in {
        formatter = pkgs.alejandra;

        packages = {
          agent-browser = pkgs.callPackage ./pkgs/agent-browser {
            inherit inputs;
          };

          nvim-lazyvim = pkgs.writeShellScriptBin "nvim-lazyvim" ''

            set -euo pipefail

            export XDG_CONFIG_HOME="${lazyvimConfig}/config"

            if [ -x /opt/homebrew/bin/nvim ]; then
              exec /opt/homebrew/bin/nvim "$@"
            elif [ -x /run/current-system/sw/bin/nvim ]; then
              exec /run/current-system/sw/bin/nvim "$@"
            elif command -v nvim >/dev/null 2>&1; then
              exec nvim "$@"
            else
              echo "nvim not found (install via Homebrew or Nix)" >&2
              exit 127
            fi
          '';

          # Treefmt wrapper for unified formatting
          treefmt = treefmtEval.config.build.wrapper;
        };

        checks = {
          pre-commit = preCommitHooks;
          darwin-eval = darwinEval;
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Nix tools
            alejandra
            statix
            deadnix
            nil
            nixd
            manix

            # Formatters
            stylua
            taplo
            nodePackages.prettier

            # Dev tools
            gitleaks
            nix-output-monitor
          ];

          # Install git hooks on shell entry
          inherit (preCommitHooks) shellHook;
        };

        apps =
          {
            nvim-lazyvim = {
              type = "app";
              program = "${self.packages.${system}.nvim-lazyvim}/bin/nvim-lazyvim";
              meta.description = "Run Neovim with vendored LazyVim config";
            };

            check-deprecations = {
              type = "app";
              program = "${pkgs.writeShellScriptBin "check-deprecations" ''
                set -euo pipefail

                tmp="$(mktemp)"
                trap 'rm -f "$tmp"' EXIT

                # Evaluate checks (no builds) and capture warnings.
                nix flake check -L --no-build 2>"$tmp" || true

                ignored_re='lib\.cli\.toGNUCommandLine(Shell)? is deprecated'

                if ${pkgs.ripgrep}/bin/rg -n "deprecated" "$tmp" | ${pkgs.ripgrep}/bin/rg -v "$ignored_re"; then
                  echo "\nFound actionable deprecations above. Fix them and re-run." >&2
                  exit 1
                fi

                if ${pkgs.ripgrep}/bin/rg -n "deprecated" "$tmp"; then
                  echo "Only upstream deprecations found (currently ignored):" >&2
                  ${pkgs.ripgrep}/bin/rg -n "deprecated" "$tmp" >&2 || true
                else
                  echo "No deprecation warnings found."
                fi
              ''}/bin/check-deprecations";
              meta.description = "List config deprecations (ignores known upstream warnings)";
            };
          }
          // (
            if isDarwin
            then {
              darwin-build = {
                type = "app";
                program = "${pkgs.writeShellScriptBin "darwin-build" ''
                  set -euo pipefail

                  if [ -n "''${FLAKE_DIR:-}" ]; then
                    flake_dir="$FLAKE_DIR"
                  elif command -v git >/dev/null 2>&1; then
                    flake_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"
                  else
                    flake_dir=""
                  fi

                  if [ -z "$flake_dir" ] || [ ! -e "$flake_dir/flake.nix" ]; then
                    flake_dir="$HOME/nix-config"
                  fi

                  if [ ! -e "$flake_dir/flake.nix" ]; then
                    echo "Could not find flake.nix. Run from the repo, or set FLAKE_DIR." >&2
                    exit 2
                  fi

                  exec ${darwinRebuild} build --flake "$flake_dir#${host}"
                ''}/bin/darwin-build";
                meta.description = "Build nix-darwin system (no switch)";
              };

              darwin-switch = {
                type = "app";
                program = "${pkgs.writeShellScriptBin "darwin-switch" ''
                  set -euo pipefail

                  if [ -n "''${FLAKE_DIR:-}" ]; then
                    flake_dir="$FLAKE_DIR"
                  elif command -v git >/dev/null 2>&1; then
                    flake_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"
                  else
                    flake_dir=""
                  fi

                  if [ -z "$flake_dir" ] || [ ! -e "$flake_dir/flake.nix" ]; then
                    flake_dir="$HOME/nix-config"
                  fi

                  if [ ! -e "$flake_dir/flake.nix" ]; then
                    echo "Could not find flake.nix. Run from the repo, or set FLAKE_DIR." >&2
                    exit 2
                  fi

                  flake_ref="$flake_dir#${host}"

                  # One-time safety: if you have pre-existing /etc files from a
                  # different Nix installer, nix-darwin will refuse to overwrite them.
                  # We back them up once using the convention it suggests.
                  exec sudo -H env FLAKE_REF="$flake_ref" ${pkgs.bash}/bin/bash -lc '
                    for f in /etc/nix/nix.conf /etc/shells; do
                      if [ -e "$f" ] && [ ! -L "$f" ]; then
                        backup="$f.before-nix-darwin"
                        if [ -e "$backup" ]; then
                          backup="$backup.$(/bin/date +%Y%m%d%H%M%S)"
                        fi
                        mv "$f" "$backup"
                      fi
                    done
                    exec ${darwinRebuild} switch --flake "$FLAKE_REF"
                  '
                ''}/bin/darwin-switch";
                meta.description = "Switch nix-darwin system (requires sudo)";
              };

              check-darwin-deprecations = {
                type = "app";
                program = "${pkgs.writeShellScriptBin "check-darwin-deprecations" ''
                  set -euo pipefail

                  tmp="$(mktemp)"
                  trap 'rm -f "$tmp"' EXIT

                  flake_dir=""
                  if [ -n "''${FLAKE_DIR:-}" ]; then
                    flake_dir="$FLAKE_DIR"
                  elif command -v git >/dev/null 2>&1; then
                    flake_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"
                  fi

                  if [ -z "$flake_dir" ] || [ ! -e "$flake_dir/flake.nix" ]; then
                    flake_dir="$HOME/nix-config"
                  fi

                  flake_ref="$flake_dir#${host}"

                  set +e
                  ${darwinRebuild} build --flake "$flake_ref" 2>"$tmp"
                  status=$?
                  set -e

                  ignored_re='lib\.cli\.toGNUCommandLine(Shell)? is deprecated'

                  if ${pkgs.ripgrep}/bin/rg -n "deprecated" "$tmp" | ${pkgs.ripgrep}/bin/rg -v "$ignored_re"; then
                    echo "\nFound actionable deprecations above. Fix them and re-run." >&2
                    exit 1
                  fi

                  if [ $status -ne 0 ]; then
                    echo "darwin build failed (exit $status)." >&2
                    ${pkgs.ripgrep}/bin/rg -n "error:" "$tmp" >&2 || true
                    exit $status
                  fi

                  echo "No actionable deprecations found in darwin build output."
                ''}/bin/check-darwin-deprecations";
                meta.description = "Check deprecations emitted by darwin-rebuild build";
              };
            }
            else {
              # Linux-specific apps
              home-switch = {
                type = "app";
                program = "${pkgs.writeShellScriptBin "home-switch" ''
                  set -euo pipefail

                  if [ -n "''${FLAKE_DIR:-}" ]; then
                    flake_dir="$FLAKE_DIR"
                  elif command -v git >/dev/null 2>&1; then
                    flake_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"
                  else
                    flake_dir=""
                  fi

                  if [ -z "$flake_dir" ] || [ ! -e "$flake_dir/flake.nix" ]; then
                    flake_dir="$HOME/nix-config"
                  fi

                  if [ ! -e "$flake_dir/flake.nix" ]; then
                    echo "Could not find flake.nix. Run from the repo, or set FLAKE_DIR." >&2
                    exit 2
                  fi

                  # Detect architecture
                  arch="$(uname -m)"
                  if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
                    config="abder@linux-arm"
                  else
                    config="abder@linux"
                  fi

                  exec ${home-manager.packages.${system}.default}/bin/home-manager switch --flake "$flake_dir#$config"
                ''}/bin/home-switch";
                meta.description = "Switch home-manager configuration on Linux";
              };
            }
          );
      };
    };
}
