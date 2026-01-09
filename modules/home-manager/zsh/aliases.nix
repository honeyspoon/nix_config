_: {
  programs.zsh.shellAliases = {
    g = "git";

    python = "python3";
    pip = "pip3";

    ls = "eza";
    cat = "bat";

    clast = "fc -s :0 | pbcopy";

    wt = "cd \"$(git worktree list | fzf | awk '{print $1}')\"";

    awscli = "awscliv2";

    vi = "nvim";
    vim = "nvim";

    nix-rebuild = "darwin-rebuild switch --flake ~/nix-config";
    nix-update = "cd ~/nix-config && nix flake update && darwin-rebuild switch --flake .";
    nix-clean = "nix-collect-garbage -d && nix-store --optimize";

    clippy-mantis = "cargo clippy --all-features -- -D warnings -W clippy::pedantic -W clippy::nursery -W clippy::cargo -A clippy::module_name_repetitions -A clippy::missing_errors_doc -A clippy::missing_panics_doc -A clippy::must_use_candidate -A clippy::return_self_not_must_use -A clippy::cargo_common_metadata -A clippy::multiple_crate_versions -A clippy::too_many_lines -A clippy::large_stack_arrays -A clippy::large_futures -A clippy::derive_partial_eq_without_eq";
    clippy-mantis-fix = "cargo clippy --fix --allow-dirty --allow-staged --all-features -- -D warnings -W clippy::pedantic -W clippy::nursery -W clippy::cargo -A clippy::module_name_repetitions -A clippy::missing_errors_doc -A clippy::missing_panics_doc -A clippy::must_use_candidate -A clippy::return_self_not_must_use -A clippy::cargo_common_metadata -A clippy::multiple_crate_versions -A clippy::too_many_lines -A clippy::large_stack_arrays -A clippy::large_futures -A clippy::derive_partial_eq_without_eq";
  };
}
