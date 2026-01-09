_: {
  programs.git = {
    enable = true;

    userName = "Abderahmane Bouziane";
    userEmail = "bobmatt911@gmail.com";

    aliases = {
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

    extraConfig = {
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

      interactive.diffFilter = "delta --color-only";

      delta = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = false;
      };

      credential = {
        "https://github.com".helper = "!/opt/homebrew/bin/gh auth git-credential";
        "https://gist.github.com".helper = "!/opt/homebrew/bin/gh auth git-credential";
      };

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

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "TwoDark";
        side-by-side = false;
        features = "decorations";

        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
          hunk-header-decoration-style = "cyan box ul";
        };

        line-numbers = {
          line-numbers-left-style = "cyan";
          line-numbers-right-style = "cyan";
          line-numbers-minus-style = "124";
          line-numbers-plus-style = "28";
        };
      };
    };
  };
}
