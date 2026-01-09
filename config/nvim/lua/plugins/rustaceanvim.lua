return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    opts = {
      server = {
        -- Rust-analyzer LSP configuration
        on_attach = function(client, bufnr)
          -- Use LazyVim's default on_attach if available
          local ok, lazyvim = pcall(require, "lazyvim.plugins.lsp.keymaps")
          if ok and lazyvim.on_attach then
            lazyvim.on_attach(client, bufnr)
          end
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust
            checkOnSave = true,
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            diagnostics = {
              enable = true,
              experimental = {
                enable = true,
              },
            },
          },
        },
      },
      -- DAP configuration
      dap = {},
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", vim.g.rustaceanvim or {}, opts or {})

      -- The plugin will handle LSP setup automatically
      -- No need to call lspconfig for rust-analyzer
    end,
  },
}
