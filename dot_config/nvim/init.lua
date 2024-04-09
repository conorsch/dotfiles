-- Set colorscheme. Reads from `~/.config/nvim/colors/*`.
vim.opt.termguicolors = true
-- The "acidcupcake" theme was copied wholesale from the vim colorscheme.
-- For reasons I don't understand, the colorscheme subtly changes
-- after Rust LSP finishes initializing, which is jarring.
vim.cmd("colorscheme acidcupcake")

-- Set leader key.
vim.g.mapleader = '\\' -- works across all nvim files

-- Enable line numbers
vim.wo.number = true
-- vim.wo.relativenumber = true

-- Tab/whitespace settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.wrap = false

-- Configure the "lazy" package manager, for installing Neovim plugins.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from ~/.config/nvim/lua/plugins.lua
require('lazy').setup('plugins')

-- Configure the nvim-tree file browser with defaults.
require("nvim-tree").setup()
