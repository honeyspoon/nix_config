return {
  -- Rainbow delimiters for better code readability
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
  },

  -- Buffer management by tab/session
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    config = true,
    init = function()
      vim.opt.sessionoptions = {
        "buffers",
        "tabpages",
        "globals",
      }
    end,
  },
  -- Git blame integration
  {
    "f-person/git-blame.nvim",
    event = "BufReadPost",
  },
  {
    "3rd/image.nvim",
  },
  {
    "NotAShelf/direnv.nvim",
    config = function()
      require("direnv").setup({})
    end,
  },
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    opts = {},
    keys = {
      {
        "ff",
        function()
          require("fff").find_files() -- or find_in_git_root() if you only want git files
        end,
        desc = "Open file picker",
      },
    },
  },
}
