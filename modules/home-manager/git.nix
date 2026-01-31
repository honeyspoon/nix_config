# Git configuration
# Consolidated: git settings, delta, gh CLI, lazycommit config files
{config, ...}: {
  programs = {
    # ══════════════════════════════════════════════════════════════════════
    # GIT CORE
    # ══════════════════════════════════════════════════════════════════════
    git = {
      enable = true;

      settings = {
        user = {
          name = "abder";
          email = "bobmatt911@gmail.com";
        };

        alias = {
          co = "checkout";
          cp = "cherry-pick";
          s = "status";
          f = "fetch";
          p = "pull";
          l = "log";
          c = "commit";
          d = "diff";
          br = "branch";
          st = "status --short";
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };

        init.defaultBranch = "main";

        core = {
          editor = "nvim";
          excludesfile = "~/.gitignore";
        };

        pull.rebase = true;
        fetch.prune = true;

        push = {
          default = "current";
          autoSetupRemote = true;
        };

        diff = {
          tool = "nvimdiff";
          colorMoved = "default";
          algorithm = "histogram";
        };

        difftool = {
          prompt = true;
          nvimdiff.cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };

        merge.conflictstyle = "diff3";

        filter.lfs = {
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
        };

        rebase = {
          autoStash = true;
          autoSquash = true;
        };

        url."git@github.com:".insteadOf = "gh:";
      };

      ignores = [
        # macOS
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"
        "._*"

        # IDEs
        ".idea/"
        ".vscode/"
        "*.swp"
        "*.swo"
        "*~"

        # Nix
        "result"
        "result-*"

        # Environment
        ".env"
        ".env.local"
        ".envrc"

        # Build artifacts
        "node_modules/"
        "target/"
        "dist/"
        "build/"
        "*.pyc"
        "__pycache__/"

        # Logs
        "*.log"
        "npm-debug.log*"
        "yarn-debug.log*"
        "yarn-error.log*"
      ];
    };

    # ══════════════════════════════════════════════════════════════════════
    # DELTA (diff pager)
    # ══════════════════════════════════════════════════════════════════════
    delta = {
      enable = true;
      enableGitIntegration = true;

      options = {
        navigate = true;
        line-numbers = true;
        line-numbers-left-style = "cyan";
        line-numbers-right-style = "cyan";
        line-numbers-minus-style = "124";
        line-numbers-plus-style = "28";
        syntax-theme = "TwoDark";
        side-by-side = false;
        features = "decorations";

        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
          hunk-header-decoration-style = "cyan box ul";
        };
      };
    };

    # ══════════════════════════════════════════════════════════════════════
    # GITHUB CLI
    # ══════════════════════════════════════════════════════════════════════
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
      };
    };

    # ══════════════════════════════════════════════════════════════════════
    # LAZYGIT (with AI commit integration)
    # ══════════════════════════════════════════════════════════════════════
    lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
          theme = {
            unstagedChangesColor = ["#db4b4b"];
            selectedLineBgColor = ["#283457"];
            searchingActiveBorderColor = ["#ff9e64" "bold"];
            optionsTextColor = ["#7aa2f7"];
            inactiveBorderColor = ["#27a1b9"];
            defaultFgColor = ["#c0caf5"];
            cherryPickedCommitFgColor = ["#7aa2f7"];
            cherryPickedCommitBgColor = ["#bb9af7"];
            activeBorderColor = ["#ff9e64" "bold"];
          };
        };

        os.editPreset = "nvim-remote";

        customCommands = [
          {
            key = "<c-g>";
            description = "Pick AI commit";
            context = "global";
            prompts = [
              {
                type = "menuFromCommand";
                title = "Select AI Commit Message";
                key = "CommitMsg";
                command = "${config.home.homeDirectory}/commit_ai.sh";
              }
            ];
            command = ''
              # Create a temporary file for the commit message
              COMMIT_MSG_FILE=$(mktemp /tmp/lazygit_ai_commit_msg.XXXXXX)
              echo "LZG_CMD_LOG: Temporary commit file created: $COMMIT_MSG_FILE"

              # Get the selected message from the menu
              SELECTED_FROM_MENU="{{.Form.CommitMsg}}"
              echo "LZG_CMD_LOG: Selected from menu (raw): >>>$SELECTED_FROM_MENU<<<"

              CLEANED_COMMIT_MSG="$SELECTED_FROM_MENU"
              echo "LZG_CMD_LOG: Cleaned commit message: >>>$CLEANED_COMMIT_MSG<<<"

              echo "$CLEANED_COMMIT_MSG" > "$COMMIT_MSG_FILE"

              echo "LZG_CMD_LOG: Opening editor (''${EDITOR:-vim}') for file: $COMMIT_MSG_FILE. PLEASE SAVE AND QUIT THE EDITOR."
              ''${EDITOR:-vim} "$COMMIT_MSG_FILE"
              EDITOR_EXIT_CODE=$?
              echo "LZG_CMD_LOG: Editor closed with exit code: $EDITOR_EXIT_CODE"

              if [ "$EDITOR_EXIT_CODE" -ne 0 ]; then
                  echo "LZG_CMD_LOG: Editor exited abnormally (code: $EDITOR_EXIT_CODE) or was cancelled. Commit aborted."
                  rm -f "$COMMIT_MSG_FILE"
              else
                  # Read the first non-comment, non-empty line after editing
                  FINAL_COMMIT_MSG=$(awk '!/^#/ && NF {print; exit}' "$COMMIT_MSG_FILE")
                  echo "LZG_CMD_LOG: Final commit message read from file: >>>$FINAL_COMMIT_MSG<<<"

                  if [ -n "$FINAL_COMMIT_MSG" ]; then
                      echo "LZG_CMD_LOG: Attempting to commit with message: >>>$FINAL_COMMIT_MSG<<<"

                      git commit -m "$FINAL_COMMIT_MSG"
                      GIT_COMMIT_EXIT_CODE=$?
                      echo "LZG_CMD_LOG: git commit exited with code: $GIT_COMMIT_EXIT_CODE"

                      if [ "$GIT_COMMIT_EXIT_CODE" -ne 0 ]; then
                          echo "LZG_CMD_LOG: GIT COMMIT FAILED."
                      else
                          echo "LZG_CMD_LOG: GIT COMMIT SUCCEEDED."
                      fi
                  else
                      echo "LZG_CMD_LOG: No valid commit message found in file after editing. Commit aborted."
                  fi
              fi

              echo "LZG_CMD_LOG: Cleaning up temp file: $COMMIT_MSG_FILE"
              rm -f "$COMMIT_MSG_FILE"
              echo "LZG_CMD_LOG: --- LAZYGIT POST-SELECTION SCRIPT FINISHED ---"
            '';
            output = "terminal";
          }
        ];
      };
    };
  };

  # ══════════════════════════════════════════════════════════════════════════
  # CONFIG FILES
  # ══════════════════════════════════════════════════════════════════════════
  home.file = {
    # AI commit script for lazygit
    "commit_ai.sh" = {
      source = ../../scripts/commit_ai.sh;
      executable = true;
    };

    # Lazycommit configuration
    ".config/.lazycommit.yaml".source = ../../config/lazycommit/.lazycommit.yaml;
    ".config/.lazycommit.prompts.yaml".source = ../../config/lazycommit/.lazycommit.prompts.yaml;
  };
}
