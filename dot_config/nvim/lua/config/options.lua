-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable relative line numbers
vim.wo.relativenumber = false

-- Disable automatic clipboard clobbering, even when deleting via `dw`.
vim.opt.clipboard = ""
-- With `unnamedplus`, only yank operations go to clipboard, which could be useful.
-- vim.opt.clipboard = "unnamedplus"

-- Disable status bar at bottom
-- Haven't figured out how to do this yet, none of these options work:
-- vim.opt.laststatus = 0
-- vim.o.laststatus = 0
-- vim.laststatus = 0
