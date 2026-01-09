{
  description = "Abder's Nix Darwin Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = [
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pkgsFor = system: import nixpkgs {inherit system;};

    preCommitFor = system:
      pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
      };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#abder-macbook
    darwinConfigurations."abder-macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./modules/darwin/configuration.nix

        # Home Manager module
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.abder = import ./modules/home-manager/home.nix;
          };
        }
      ];
    };

    legacyPackages = forAllSystems pkgsFor;

    formatter = forAllSystems (system: (pkgsFor system).alejandra);

    checks = forAllSystems (
      system: let
        pkgs = pkgsFor system;
        preCommitCheck = preCommitFor system;

        # Evaluate the full nix-darwin configuration during `nix flake check`
        # so module/option errors surface early, without forcing a full build.
        darwinEval = pkgs.runCommand "darwin-eval" {} (
          builtins.seq self.darwinConfigurations."abder-macbook".system ''
            echo ok > $out
          ''
        );
      in {
        pre-commit = preCommitCheck;
        darwin-eval = darwinEval;
      }
    );

    devShells = forAllSystems (
      system: let
        pkgs = pkgsFor system;
        preCommitCheck = preCommitFor system;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            statix
            deadnix
            nil
            pre-commit
          ];

          inherit (preCommitCheck) shellHook;
        };
      }
    );

    apps = forAllSystems (
      system: let
        pkgs = pkgsFor system;
        darwinRebuild = "${nix-darwin.packages.${system}.default}/bin/darwin-rebuild";
        flakeRef = "$HOME/nix-config#abder-macbook";
      in {
        darwin-build = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "darwin-build" ''
            set -euo pipefail
            exec ${darwinRebuild} build --flake "${flakeRef}"
          ''}/bin/darwin-build";
          meta.description = "Build nix-darwin system (no switch)";
        };

        darwin-switch = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "darwin-switch" ''
            set -euo pipefail

            # Preserve the invoking user's flake path.
            flake_ref="$HOME/nix-config#abder-macbook"

            # One-time safety: if you have pre-existing /etc files from a
            # different Nix installer, nix-darwin will refuse to overwrite them.
            # We back them up once using the convention it suggests.
            exec sudo -H env FLAKE_REF="$flake_ref" ${pkgs.bash}/bin/bash -lc '
              for f in /etc/nix/nix.conf /etc/bashrc /etc/zshrc; do
                if [ -e "$f" ] && [ ! -L "$f" ] && [ ! -e "$f.before-nix-darwin" ]; then
                  mv "$f" "$f.before-nix-darwin"
                fi
              done
              exec ${darwinRebuild} switch --flake "$FLAKE_REF"
            '
          ''}/bin/darwin-switch";
          meta.description = "Switch nix-darwin system (requires sudo)";
        };
      }
    );
  };
}
