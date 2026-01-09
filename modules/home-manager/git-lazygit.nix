_: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
        theme = {
          unstagedChangesColor = ["#db4b4b"];
          selectedLineBgColor = ["#283457"];
          searchingActiveBorderColor = [
            "#ff9e64"
            "bold"
          ];
          optionsTextColor = ["#7aa2f7"];
          inactiveBorderColor = ["#27a1b9"];
          defaultFgColor = ["#c0caf5"];
          cherryPickedCommitFgColor = ["#7aa2f7"];
          cherryPickedCommitBgColor = ["#bb9af7"];
          activeBorderColor = [
            "#ff9e64"
            "bold"
          ];
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
              command = "/Users/abder/commit_ai.sh";
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
}
