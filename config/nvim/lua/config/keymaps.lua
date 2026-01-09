vim.keymap.set("n", "<Char-0xAA>", "<cmd>write<cr>", {
  desc = "N: Save current file by <command-s>",
})
vim.keymap.set({ "n", "t" }, "<C-S-h>", require("smart-splits").resize_left)
vim.keymap.set({ "n", "t" }, "<C-S-j>", require("smart-splits").resize_down)
vim.keymap.set({ "n", "t" }, "<C-S-k>", require("smart-splits").resize_up)
vim.keymap.set({ "n", "t" }, "<C-S-l>", require("smart-splits").resize_right)

vim.keymap.set({ "n", "t" }, "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set({ "n", "t" }, "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set({ "n", "t" }, "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set({ "n", "t" }, "<C-l>", require("smart-splits").move_cursor_right)

vim.keymap.set({ "n", "t" }, "<leader><leader>h", require("smart-splits").swap_buf_left)
vim.keymap.set({ "n", "t" }, "<leader><leader>j", require("smart-splits").swap_buf_down)
vim.keymap.set({ "n", "t" }, "<leader><leader>k", require("smart-splits").swap_buf_up)
vim.keymap.set({ "n", "t" }, "<leader><leader>l", require("smart-splits").swap_buf_right)

vim.keymap.set("v", "<leader>r", function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if type(lines) ~= "table" then
    lines = { lines }
  end

  local selection = table.concat(lines, "\n")

  -- Create a function table to execute
  local func = loadstring(selection)
  if type(func) == "function" then
    local success, result = pcall(func)
    if not success then
      print("Error executing Lua code: ", result)
    else
      print("Execution successful")
    end
  else
    print("Error: Selection is not valid Lua code")
  end
end, { desc = "Execute visual selection in Lua" })

vim.keymap.set("n", "<leader>G", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local gh_dash = Terminal:new({
    cmd = "gh dash",
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
    },
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
    on_close = function(term)
      vim.cmd("stopinsert!")
    end,
  })

  gh_dash:toggle()
end, { desc = "github dash" })

-- Store the terminal instance outside the function
local btop_term = nil

vim.keymap.set("n", "<leader>bt", function()
  if not btop_term then
    local Terminal = require("toggleterm.terminal").Terminal
    btop_term = Terminal:new({
      cmd = "btop",
      direction = "float",
      close_on_exit = false, -- Don't kill on exit
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        -- Map 'q' to hide instead of kill
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
      on_close = function(term)
        vim.cmd("stopinsert!")
      end,
    })
  end
  btop_term:toggle()
end, { desc = "btop" })

-- Store the scratch terminal instance
local scratch_term = nil

local function toggle_scratch_term()
  if not scratch_term then
    local Terminal = require("toggleterm.terminal").Terminal
    scratch_term = Terminal:new({
      direction = "float",
      close_on_exit = false, -- Don't kill on exit
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        -- Map 'q' to hide instead of kill
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "`", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
      on_close = function(term)
        vim.cmd("stopinsert!")
      end,
    })
  end
  scratch_term:toggle()
end

-- Set keymap for both normal and terminal modes
vim.keymap.set({ "n", "t" }, "<leader>`", toggle_scratch_term, { desc = "Toggle scratch floating terminal" })

vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-N>:lua ClearTerm(0)<CR>]], {})

function ClearTerm(reset)
  vim.opt_local.scrollback = 1

  vim.api.nvim_command("startinsert")
  if reset == 1 then
    vim.api.nvim_feedkeys("reset", "t", false)
  else
    vim.api.nvim_feedkeys("clear", "t", false)
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, false, true), "t", true)

  vim.opt_local.scrollback = 10000
end

vim.keymap.set({ "n" }, "<D-s>", "<cmd>:w<cr>")
