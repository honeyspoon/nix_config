return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disabled servers
        tflint = false,

        -- TailwindCSS - Fix dynamic registration warning
        -- This fixes: "triggers a registerCapability handler despite dynamicRegistration set to false"
        tailwindcss = {
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.workspace.didChangeConfiguration.dynamicRegistration = true
            return capabilities
          end)(),
        },

        -- JSON LSP - Fix diagnostic refresh errors
        -- This fixes: "no handler found for workspace/diagnostic/refresh"
        jsonls = {
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- Disable pull diagnostics that json-lsp doesn't support
            capabilities.textDocument.diagnostic = nil
            return capabilities
          end)(),
          settings = {
            json = {
              validate = { enable = true },
            },
          },
        },

        -- Marksman - Fix bogus workspace warnings
        -- This fixes: "Workspace folder is bogus" for temp directories
        marksman = {
          root_dir = function(fname)
            -- fname can be a buffer number or filepath, convert to string
            if type(fname) ~= "string" then
              fname = vim.api.nvim_buf_get_name(fname)
            end

            local util = require("lspconfig.util")
            -- Only attach to actual markdown projects with .git or .marksman.toml
            return util.root_pattern(".git", ".marksman.toml")(fname) or util.find_git_ancestor(fname)
          end,
        },

        -- Bash LSP - Better file handling
        bashls = {
          settings = {
            bashIde = {
              globPattern = "**/*@(.sh|.inc|.bash|.command)",
            },
          },
        },

        -- Taplo (TOML) - INFO messages are harmless, just verbose logging
        -- No config needed, the "ERROR" logs are actually INFO sent to stderr
        taplo = {},
      },
    },
  },
}
