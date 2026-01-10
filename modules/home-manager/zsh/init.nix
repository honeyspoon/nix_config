{config, ...}: {
  programs.zsh.initContent = ''
    # Increase file descriptor limit for Rust builds
    ulimit -n 10240

    # Load Powerlevel10k theme
    if [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
      source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
    fi

    # Load P10k config if exists
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    # Load antigen for additional plugins
    if [[ -f /opt/homebrew/share/antigen/antigen.zsh ]]; then
      source /opt/homebrew/share/antigen/antigen.zsh

      antigen bundle mroth/evalcache
      antigen bundle zsh-users/zsh-syntax-highlighting
      antigen bundle zsh-users/zsh-autosuggestions
      antigen bundle zsh-users/zsh-completions
      antigen bundle ael-code/zsh-colored-man-pages
      antigen bundle jeffreytse/zsh-vi-mode
      antigen bundle macunha1/zsh-terraform

      antigen theme romkatv/powerlevel10k
      antigen apply
    fi

    # NVM integration
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

    # Cargo binaries (append so Nix-provided tools win)
    if [ -d "$HOME/.cargo/bin" ]; then
      case ":$PATH:" in
        *":$HOME/.cargo/bin:"*) ;;
        *) export PATH="$PATH:$HOME/.cargo/bin" ;;
      esac
    fi

    # jenv (Java version manager)
    if command -v jenv &>/dev/null; then
      export PATH="$HOME/.jenv/bin:$PATH"
      eval "$(jenv init -)"
    fi

    # LM Studio CLI
    export PATH="$PATH:${config.home.homeDirectory}/.lmstudio/bin"

    # PostgreSQL 17
    export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

    # Solana CLI
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

    # Amp CLI
    export PATH="${config.home.homeDirectory}/.amp/bin:$PATH"

    # OpenCode
    export PATH="${config.home.homeDirectory}/.opencode/bin:$PATH"

    # Bun completions
    [ -s "${config.home.homeDirectory}/.bun/_bun" ] && source "${config.home.homeDirectory}/.bun/_bun"

    # Conda initialization
    if [ -f /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh ]; then
      source /opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh
    fi

    # Clear screen on shell start
    clear
  '';
}
