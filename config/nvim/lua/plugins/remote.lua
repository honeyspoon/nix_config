return {
  "amitds1997/remote-nvim.nvim",
  -- "p1scescom/remote-nvim.nvim",
  branch = "main",
  dependencies = {
    "nvim-lua/plenary.nvim", -- For standard functions
    "MunifTanjim/nui.nvim", -- To build the plugin UI
    "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
  },
  config = true,
}
