-- Options are automatically loaded before lazy.nvim startup

-- SYNC CLIPBOARD: Allows copying to system clipboard (Cmd+C/V)
vim.opt.clipboard = "unnamedplus"

-- GLOBAL STATUSLINE: Single statusline at the bottom
vim.opt.laststatus = 3

-- NOTIFICATION PADDING
vim.opt.signcolumn = "yes:2"

-- HUD MODE: Hide command line when not typing (requires Noice plugin)
vim.opt.cmdheight = 0

-- NAVIGATION
vim.opt.number = true
vim.opt.relativenumber = true

-- LSP PRIORITIES
vim.highlight.priorities.semantic_tokens = 95

-- LSP LOG LEVEL: Reduce log verbosity (warn = only warnings and errors)
vim.lsp.log.level = "warn" -- Options: "trace", "debug", "info", "warn", "error", "off"
