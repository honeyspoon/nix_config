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
        preCommitCheck = preCommitFor system;
      in {
        pre-commit = preCommitCheck;
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
  };
}
