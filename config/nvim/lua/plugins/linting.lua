return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Ensure the configuration table exists
      opts.linters_by_ft = opts.linters_by_ft or {}

      -- Explicitly disable linting for markdown files
      -- This stops MD013, MD022, and other markdownlint errors
      opts.linters_by_ft.markdown = {}
    end,
  },
}
