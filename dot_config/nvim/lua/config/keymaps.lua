-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Function to remove trailing whitespace
local function remove_trailing_whitespace()
  -- Save cursor position
  local cursor_position = vim.fn.winsaveview()

  -- Remove trailing whitespace
  vim.cmd([[keeppatterns %s/\s\+$//e]])

  -- Restore cursor position
  vim.fn.winrestview(cursor_position)

  -- Show confirmation message
  vim.api.nvim_echo({ { " Trailing whitespace removed", "Normal" } }, false, {})
end

-- Map \w to remove trailing whitespace
vim.keymap.set("n", "<leader>w", remove_trailing_whitespace, { desc = "Remove trailing whitespace" })
