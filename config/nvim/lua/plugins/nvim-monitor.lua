return {
  dir = "~/projects/nvim-monitor",
  name = "nvim-monitor",
  build = "cargo build --release",
  cmd = { "NvimMonitor", "NvimMonitorBuild", "NvimMonitorExport" },
  keys = {
    { "<leader>pm", "<cmd>NvimMonitor<cr>", desc = "Open nvim-monitor" },
    { "<leader>pe", "<cmd>NvimMonitorExport<cr>", desc = "Export diagnostics" },
  },
  config = function()
    require("nvim-monitor").setup({
      keymaps = {
        open = "<leader>pm",
        export = "<leader>pe",
      },
    })
  end,
}
