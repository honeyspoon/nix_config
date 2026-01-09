return {
  -- Project management
  {
    "ahmedkhalf/project.nvim",
    opts = {
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
      silent_chdir = true,
    },
    event = "VeryLazy",
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
  },

  -- ADD THIS: Integrate Project with Telescope automatically
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      opts.extensions = opts.extensions or {}
      opts.extensions.projects = {}
      -- This loads the extension when telescope opens
      require("telescope").load_extension("projects")
    end,
  },
}
