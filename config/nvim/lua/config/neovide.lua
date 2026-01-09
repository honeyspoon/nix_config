if vim.g.neovide then
  -- Font and scaling
  vim.o.guifont = "Hack Nerd Font:h12"
  vim.g.neovide_scale_factor = 1.4
  vim.g.neovide_input_macos_option_key_is_meta = "both"

  -- Disable animations and effects
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0.05

  -- macOS keybindings
  vim.api.nvim_set_keymap("n", "<D-w>", ":x<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<D-q>", ":qall<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<D-s>", ":w<CR>", { silent = true })
  vim.api.nvim_set_keymap("i", "<D-v>", "<C-r>+", { silent = true })

  -- Scale up/down bindings
  vim.api.nvim_set_keymap(
    "n",
    "<D-=>",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>",
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<D-->",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>",
    { silent = true }
  )

  -- Appearance settings
  vim.opt.termguicolors = false
  vim.g.neovide_transparency = 0.8
  vim.g.neovide_normal_opacity = 0.9
  vim.g.neovide_floating_corner_radius = 1

  -- Padding
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_left = 20

  vim.g.neovide_show_border = true
end
