return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "right",
        width = 35, -- Fixed width is often better for right-side alignment
      },
      source_selector = {
        winbar = true, -- Adds tabs to the top of the tree
        statusline = false,
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },
  {
    "snacks.nvim",
    opts = {
      dashboard = { enabled = true }, -- ENABLE DASHBOARD
      notifier = {
        enabled = true,
        position = "top-left", -- Position notifications on the left side
        max_height = 10,
        max_width = 60,
        timeout = 3000,
        icons = {
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = "✎ ",
        },
      },
      -- Enable other Snacks modules you're using
      indent = { enabled = true },
      input = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- We configure this in options.lua
      words = { enabled = true },
    },
    keys = {
      {
        "<leader>n",
        function()
          require("snacks").notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
    },
  },
}
