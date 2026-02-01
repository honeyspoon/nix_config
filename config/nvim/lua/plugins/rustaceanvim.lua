return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    opts = {
      server = {
        -- Use lspmux to share rust-analyzer instance between editors
        cmd = function()
          -- Prefer nix-provided rust-analyzer over rustup's proxy
          -- (rustup proxy fails for nightly toolchains without rust-analyzer component)
          local home = os.getenv("HOME")
          local user = os.getenv("USER") or "abder"
          local nix_paths = {
            -- macOS nix-darwin home-manager profile
            "/etc/profiles/per-user/"
              .. user
              .. "/bin/rust-analyzer",
            -- macOS nix-darwin system profile
            "/run/current-system/sw/bin/rust-analyzer",
            -- Linux home-manager profile
            home .. "/.nix-profile/bin/rust-analyzer",
          }

          local ra_path = "rust-analyzer"
          for _, path in ipairs(nix_paths) do
            local f = io.open(path, "r")
            if f then
              f:close()
              ra_path = path
              break
            end
          end

          -- Check if lspmux server is running
          local handle = io.popen("lspmux status 2>/dev/null")
          if handle then
            local result = handle:read("*a")
            handle:close()
            if result and result:match("running") then
              return { "lspmux", "--server-path", ra_path }
            end
          end
          -- Fallback to direct rust-analyzer
          return { ra_path }
        end,
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
              -- Use nix cargo/rustc by setting PATH to prioritize nix paths
              -- and unsetting CARGO_HOME/RUSTUP_HOME to prevent rustup discovery
              extraEnv = {
                PATH = (function()
                  local user = os.getenv("USER") or "abder"
                  local home = os.getenv("HOME")
                  local nix_paths = {
                    "/etc/profiles/per-user/" .. user .. "/bin",
                    "/run/current-system/sw/bin",
                    home .. "/.nix-profile/bin",
                    "/nix/var/nix/profiles/default/bin",
                  }
                  return table.concat(nix_paths, ":") .. ":" .. (os.getenv("PATH") or "")
                end)(),
                -- Unset these to prevent rust-analyzer from using rustup proxies
                CARGO_HOME = "",
                RUSTUP_HOME = "",
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
