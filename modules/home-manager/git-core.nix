_: {
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "Abderahmane Bouziane";
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

        # `programs.delta` manages `interactive.diffFilter`.

        # GitHub credential helper is managed by `programs.gh`.

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
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"
        "._*"

        ".idea/"
        ".vscode/"
        "*.swp"
        "*.swo"
        "*~"

        "result"
        "result-*"

        ".env"
        ".env.local"
        ".envrc"

        "node_modules/"
        "target/"
        "dist/"
        "build/"
        "*.pyc"
        "__pycache__/"

        "*.log"
        "npm-debug.log*"
        "yarn-debug.log*"
        "yarn-error.log*"
      ];
    };

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
  };
}
