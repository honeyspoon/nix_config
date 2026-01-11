{
  description = "Abder's Nix Darwin Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    home-manager,
    sops-nix,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
      ];

      flake = let
        user = {
          name = "abder";
          home = "/Users/abder";
        };

        host = "abder-macbook";
      in {
        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#${host}
        darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
          specialArgs = {inherit user host;};
          system = "aarch64-darwin";
          modules = [
            ./modules/darwin/configuration.nix

            # Expose wrapped apps as pkgs.* within nix-darwin
            {nixpkgs.overlays = [self.overlays.default];}

            # Home Manager module
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                # When Home Manager is enabled as a nix-darwin module, it will refuse
                # to overwrite pre-existing dotfiles. Back them up once so the first
                # `darwin-switch` succeeds.
                backupFileExtension = "before-nix-home-manager";

                extraSpecialArgs = {inherit user host;};

                sharedModules = [
                  sops-nix.homeManagerModules.sops
                  ./modules/home-manager/secrets.nix
                ];

                users.${user.name} = import ./modules/home-manager/home.nix;
              };
            }
          ];
        };

        overlays.default = _final: prev: {
          inherit
            (self.packages.${prev.stdenv.hostPlatform.system})
            nvim-lazyvim
            opencode-wrapped
            ;
        };
      };

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        preCommitCheck =
          pkgs.runCommand "lint"
          {
            src = ./.;
            nativeBuildInputs = [
              pkgs.alejandra
              pkgs.deadnix
              pkgs.gitleaks
              pkgs.nodePackages.prettier
              pkgs.statix
              pkgs.stylua
              pkgs.taplo
            ];
          }
          ''
            export HOME="$TMPDIR"
            export XDG_CACHE_HOME="$TMPDIR"

            cp -R "$src" repo
            chmod -R u+w repo
            cd repo

            alejandra --check .
            deadnix --fail .
            statix check .
            stylua --check config/nvim
            taplo fmt --check .
            prettier --ignore-unknown --check .
            gitleaks detect --source . --no-git --redact --config .gitleaks.toml

            echo ok > "$out"
          '';

        devShellHook = ''
          export PRE_COMMIT_COLOR=always
          export PRE_COMMIT_CONFIG="$PWD/pre-commit-config.yaml"

          if [ -d .git ]; then
            pre-commit install -f --config "$PRE_COMMIT_CONFIG" --install-hooks >/dev/null 2>&1 || true
          fi
        '';

        host = "abder-macbook";
        darwinRebuild = "${nix-darwin.packages.${system}.default}/bin/darwin-rebuild";

        # Evaluate the full nix-darwin configuration during `nix flake check`
        # so module/option errors surface early, without forcing a full build.
        darwinEval = pkgs.runCommand "darwin-eval" {} (
          builtins.seq self.darwinConfigurations.${host}.system ''
            echo ok > $out
          ''
        );

        lazyvimConfig = pkgs.runCommand "lazyvim-config" {} ''
          mkdir -p "$out/config"
          cp -R "${./config/nvim}" "$out/config/nvim"
        '';
      in {
        formatter = pkgs.alejandra;

        packages = {
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

          opencode-wrapped = pkgs.writeShellScriptBin "opencode-wrapped" ''
            set -euo pipefail

            if command -v opencode >/dev/null 2>&1; then
              exec opencode "$@"
            else
              echo "opencode not found" >&2
              exit 127
            fi
          '';
        };

        checks = {
          pre-commit = preCommitCheck;
          darwin-eval = darwinEval;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            statix
            deadnix
            stylua
            taplo
            nodePackages.prettier
            nil
            pre-commit
            gitleaks
          ];

          shellHook = devShellHook;
        };

        apps = {
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

          nvim-lazyvim = {
            type = "app";
            program = "${self.packages.${system}.nvim-lazyvim}/bin/nvim-lazyvim";
            meta.description = "Run Neovim with vendored LazyVim config";
          };

          opencode-wrapped = {
            type = "app";
            program = "${self.packages.${system}.opencode-wrapped}/bin/opencode-wrapped";
            meta.description = "Run OpenCode with nix-managed config and commands";
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
        };
      };
    };
}
