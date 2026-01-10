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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    pre-commit-hooks,
    sops-nix,
    ...
  }: let
    supportedSystems = [
      "aarch64-darwin"
    ];

    user = {
      name = "abder";
      home = "/Users/abder";
    };

    host = "abder-macbook";

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pkgsFor = system: import nixpkgs {inherit system;};

    preCommitFor = system: let
      pkgs = pkgsFor system;
    in
      pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix.enable = true;
          deadnix.enable = true;

          # Neovim/LazyVim config
          stylua.enable = true;

          # Format common config formats
          taplo.enable = true;
          prettier.enable = true;

          gitleaks = {
            enable = true;
            name = "gitleaks";
            entry = "${pkgs.gitleaks}/bin/gitleaks detect --source . --no-git --redact --config .gitleaks.toml";
          };
        };
      };
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

    legacyPackages = forAllSystems pkgsFor;

    formatter = forAllSystems (system: (pkgsFor system).alejandra);

    overlays.default = _final: prev: {
      inherit
        (self.packages.${prev.stdenv.hostPlatform.system})
        nvim-lazyvim
        opencode-wrapped
        ;
    };

    checks = forAllSystems (
      system: let
        pkgs = pkgsFor system;
        preCommitCheck = preCommitFor system;

        # Evaluate the full nix-darwin configuration during `nix flake check`
        # so module/option errors surface early, without forcing a full build.
        darwinEval = pkgs.runCommand "darwin-eval" {} (
          builtins.seq self.darwinConfigurations.${host}.system ''
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
            stylua
            taplo
            nodePackages.prettier
            nil
            pre-commit
            gitleaks
          ];

          inherit (preCommitCheck) shellHook;
        };
      }
    );

    packages = forAllSystems (
      system: let
        pkgs = pkgsFor system;

        lazyvimConfig = pkgs.runCommand "lazyvim-config" {} ''
          mkdir -p "$out/config"
          cp -R "${./config/nvim}" "$out/config/nvim"
        '';

        opencodeWrappedConfig = pkgs.runCommand "opencode-wrapped-config" {} ''
          mkdir -p "$out/opencode"

          cat > "$out/opencode/opencode-bell.md" <<'EOF'
          # Attention bell

          When you are about to WAIT for user input (a question, a choice, confirmation, or approval), output a terminal bell character exactly once on its own line:

          \a

          Then ask the question / request the confirmation.

          Also output \a once when you are completely done and no further user input is required.
          EOF

          cat > "$out/opencode/.opencode.json" <<EOF
          {
            "autoCompact": true,
            "shell": { "path": "/bin/zsh", "args": ["-l"] },
            "contextPaths": [
              "$out/opencode/opencode-bell.md",
              ".github/copilot-instructions.md",
              ".cursorrules",
              ".cursor/rules/",
              "CLAUDE.md",
              "CLAUDE.local.md",
              "opencode.md",
              "opencode.local.md",
              "OpenCode.md",
              "OpenCode.local.md",
              "OPENCODE.md",
              "OPENCODE.local.md"
            ]
          }
          EOF

          mkdir -p "$out/opencode/commands"
          if [ -d "${./config/opencode/commands}" ]; then
            cp -R "${./config/opencode/commands}/." "$out/opencode/commands/"
          fi
        '';
      in {
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

          export XDG_CONFIG_HOME="${opencodeWrappedConfig}"

          if [ -x "$HOME/.opencode/bin/opencode" ]; then
            exec "$HOME/.opencode/bin/opencode" "$@"
          elif command -v opencode >/dev/null 2>&1; then
            exec opencode "$@"
          else
            echo "opencode not found; install via the curl installer" >&2
            exit 127
          fi
        '';
      }
    );

    apps = forAllSystems (
      system: let
        pkgs = pkgsFor system;
        darwinRebuild = "${nix-darwin.packages.${system}.default}/bin/darwin-rebuild";
      in {
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
      }
    );
  };
}
