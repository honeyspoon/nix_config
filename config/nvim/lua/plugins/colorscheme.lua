return {
  -- Tokyonight theme with the darker "night" variant
  {
    "folke/tokyonight.nvim",
    lazy = false, -- Load immediately
    opts = {
      style = "night", -- The darker variant
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "terminal", "Telegraph", "neo-tree" },
      dim_inactive = false,
      lualine_bold = false,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
