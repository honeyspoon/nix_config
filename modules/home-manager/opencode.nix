{config, ...}: let
  bellPath = "${config.xdg.configHome}/opencode/opencode-bell.md";

  # Use nix-provided rust-analyzer to avoid rustup proxy issues with nightly toolchains
  rustAnalyzerPath = "${config.home.profileDirectory}/bin/rust-analyzer";

  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";

    # Tokyo Night theme
    theme = "tokyo-night";

    # Disable permission prompts (always allow).
    permission = "allow";

    # Custom commands
    command = {
      mystatus = {
        description = "Query quota usage for all AI accounts";
        template = "Use the mystatus tool to query quota usage. Return the result as-is without modification.";
      };
    };

    # LSP configuration
    lsp = {
      terraform.disabled = true;
      # Use lspmux to share rust-analyzer instance between editors
      # Uses nix rust-analyzer to avoid rustup proxy issues with nightly toolchains
      rust-analyzer = {
        command = ["lspmux" "--server-path" rustAnalyzerPath];
        extensions = ["rs"];
      };
    };

    # MCP servers
    mcp = {
      datadog = {
        type = "local";
        # Run via interactive shell to get sops-decrypted env vars (DATADOG_API_KEY, etc.)
        command = [
          "zsh"
          "-i"
          "-c"
          "exec npx -y @winor30/mcp-server-datadog"
        ];
      };
      shadcn = {
        type = "local";
        command = ["npx" "shadcn@latest" "mcp"];
      };
    };

    plugin = [
      "opencode-openai-codex-auth"
      "@tarquinen/opencode-dcp@latest" # Dynamic Context Pruning - reduces token usage
    ];

    provider = {
      openai = {
        options = {
          reasoningEffort = "medium";
          reasoningSummary = "auto";
          textVerbosity = "medium";
          include = ["reasoning.encrypted_content"];
          store = false;
        };
        models = {
          "gpt-5.2" = {
            name = "GPT 5.2 (OAuth)";
            limit = {
              context = 272000;
              output = 128000;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
            variants = {
              none = {
                reasoningEffort = "none";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              low = {
                reasoningEffort = "low";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              medium = {
                reasoningEffort = "medium";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              high = {
                reasoningEffort = "high";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
              xhigh = {
                reasoningEffort = "xhigh";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
            };
          };
          "gpt-5.2-codex" = {
            name = "GPT 5.2 Codex (OAuth)";
            limit = {
              context = 272000;
              output = 128000;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
            variants = {
              low = {
                reasoningEffort = "low";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              medium = {
                reasoningEffort = "medium";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              high = {
                reasoningEffort = "high";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
              xhigh = {
                reasoningEffort = "xhigh";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
            };
          };
          "gpt-5.1-codex-max" = {
            name = "GPT 5.1 Codex Max (OAuth)";
            limit = {
              context = 272000;
              output = 128000;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
            variants = {
              low = {
                reasoningEffort = "low";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
              medium = {
                reasoningEffort = "medium";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
              high = {
                reasoningEffort = "high";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
              xhigh = {
                reasoningEffort = "xhigh";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
            };
          };
          "gpt-5.1-codex" = {
            name = "GPT 5.1 Codex (OAuth)";
            limit = {
              context = 272000;
              output = 128000;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
            variants = {
              low = {
                reasoningEffort = "low";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              medium = {
                reasoningEffort = "medium";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              high = {
                reasoningEffort = "high";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
            };
          };
          "gpt-5.1-codex-mini" = {
            name = "GPT 5.1 Codex Mini (OAuth)";
            limit = {
              context = 272000;
              output = 128000;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
            variants = {
              medium = {
                reasoningEffort = "medium";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              high = {
                reasoningEffort = "high";
                reasoningSummary = "detailed";
                textVerbosity = "medium";
              };
            };
          };
          "gpt-5.1" = {
            name = "GPT 5.1 (OAuth)";
            limit = {
              context = 272000;
              output = 128000;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
            variants = {
              none = {
                reasoningEffort = "none";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              low = {
                reasoningEffort = "low";
                reasoningSummary = "auto";
                textVerbosity = "low";
              };
              medium = {
                reasoningEffort = "medium";
                reasoningSummary = "auto";
                textVerbosity = "medium";
              };
              high = {
                reasoningEffort = "high";
                reasoningSummary = "detailed";
                textVerbosity = "high";
              };
            };
          };
        };
      };

      google = {
        models = {
          antigravity-gemini-3-pro = {
            name = "Gemini 3 Pro (Antigravity)";
            limit = {
              context = 1048576;
              output = 65535;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
            variants = {
              low = {
                thinkingLevel = "low";
              };
              high = {
                thinkingLevel = "high";
              };
            };
          };

          antigravity-gemini-3-flash = {
            name = "Gemini 3 Flash (Antigravity)";
            limit = {
              context = 1048576;
              output = 65536;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
            variants = {
              minimal = {
                thinkingLevel = "minimal";
              };
              low = {
                thinkingLevel = "low";
              };
              medium = {
                thinkingLevel = "medium";
              };
              high = {
                thinkingLevel = "high";
              };
            };
          };

          antigravity-claude-sonnet-4-5 = {
            name = "Claude Sonnet 4.5 (no thinking) (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
          };

          antigravity-claude-sonnet-4-5-thinking = {
            name = "Claude Sonnet 4.5 Thinking (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
            variants = {
              low = {
                thinkingConfig = {
                  thinkingBudget = 8192;
                };
              };
              max = {
                thinkingConfig = {
                  thinkingBudget = 32768;
                };
              };
            };
          };

          antigravity-claude-opus-4-5-thinking = {
            name = "Claude Opus 4.5 Thinking (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
            variants = {
              low = {
                thinkingConfig = {
                  thinkingBudget = 8192;
                };
              };
              max = {
                thinkingConfig = {
                  thinkingBudget = 32768;
                };
              };
            };
          };

          "gemini-2.5-flash" = {
            name = "Gemini 2.5 Flash (Gemini CLI)";
            limit = {
              context = 1048576;
              output = 65536;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
          };

          "gemini-2.5-pro" = {
            name = "Gemini 2.5 Pro (Gemini CLI)";
            limit = {
              context = 1048576;
              output = 65536;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
          };

          gemini-3-flash-preview = {
            name = "Gemini 3 Flash Preview (Gemini CLI)";
            limit = {
              context = 1048576;
              output = 65536;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
          };

          gemini-3-pro-preview = {
            name = "Gemini 3 Pro Preview (Gemini CLI)";
            limit = {
              context = 1048576;
              output = 65535;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = ["text"];
            };
          };
        };
      };
    };

    instructions = [
      bellPath
      ".github/copilot-instructions.md"
      ".cursorrules"
      ".cursor/rules/"
      "CLAUDE.md"
      "CLAUDE.local.md"
      "opencode.md"
      "opencode.local.md"
      "OpenCode.md"
      "OpenCode.local.md"
      "OPENCODE.md"
      "OPENCODE.local.md"
    ];
  };
in {
  xdg.configFile = {
    "opencode/opencode-bell.md".text = ''
      # Attention bell

      When you are about to WAIT for user input (a question, a choice, confirmation, or approval), output a terminal bell character exactly once on its own line:

      \a

      Then ask the question / request the confirmation.

      Also output \a once when you are completely done and no further user input is required.
    '';

    "opencode/opencode.jsonc".text = builtins.toJSON opencodeConfig;

    "opencode/command" = {
      source = ../../config/opencode/commands;
      recursive = true;
    };

    "opencode/skill" = {
      source = ../../config/opencode/skill;
      recursive = true;
    };
  };
}
