return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  opts = {
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = {
      "nofile",
      "quickfix",
      "qf",
      "prompt",
    },
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = { "nofile", "quickfix", "prompt" },
    -- Stop at the edge of the screen instead of wrapping
    at_edge = "stop",
    -- When resizing, keep the cursor in the same relative position
    cursor_follow_current_win = true,
    -- The default multiplier for moving when using the directional keys
    default_amount = 3,
    -- Wezterm integration
    wezterm = {
      enabled = true,
      font_size = function(font_size)
        return font_size + 2
      end,
    },
  },
  config = function(_, opts)
    require("smart-splits").setup(opts)
    -- Key bindings are handled in config/keymaps.lua
  end,
}
