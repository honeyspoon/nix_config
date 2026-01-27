-- diagram.nvim - Render diagrams in Neovim (mermaid, plantuml, d2, gnuplot)
-- https://github.com/3rd/diagram.nvim
-- Requires: image.nvim + terminal with image support (Kitty, WezTerm, Ghostty)
return {
  "3rd/diagram.nvim",
  dependencies = {
    "3rd/image.nvim",
  },
  ft = { "markdown", "plantuml", "mermaid" },
  opts = {
    renderer_options = {
      mermaid = {
        background = "transparent",
        theme = "dark",
      },
      plantuml = {
        charset = "utf-8",
      },
      d2 = {
        theme_id = 200, -- dark theme
        sketch = false,
      },
      gnuplot = {
        theme = "dark",
      },
    },
  },
  keys = {
    {
      "<leader>cd",
      function()
        require("diagram").show_diagram_hover()
      end,
      desc = "Show diagram",
      ft = { "markdown" },
    },
  },
}
