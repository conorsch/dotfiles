-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Toggle autoformat behavior on save per language, via
-- https://github.com/LazyVim/LazyVim/discussions/141#discussioncomment-9266704
local set_autoformat = function(pattern, bool_val)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = pattern,
    callback = function()
      vim.b.autoformat = bool_val
    end,
  })
end

-- N.B. "sh" also includes "bash".
set_autoformat({ "sh" }, false)
set_autoformat({ "json" }, false)
set_autoformat({ "lua" }, true)
set_autoformat({ "rust" }, true)
set_autoformat({ "toml" }, false)
set_autoformat({ "yaml" }, false)

-- Toggle "conceal" behavior which hides certain characters.
local disable_conceal = function(pattern)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = pattern,
    callback = function()
      vim.opt_local.conceallevel = 0
    end,
  })
end
-- Disable concealing on Markdown files, to avoid hiding triple-backticks in code block in code blocks.
disable_conceal({ "markdown" })

-- Force NerdTree file browser on always.
-- via https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/679
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("NeotreeOnOpen", { clear = true }),
  once = true,
  callback = function(_)
    if vim.fn.argc() == 0 then
      vim.cmd("Neotree")
    end
  end,
})

vim.api.nvim_create_autocmd("TabNew", {
  group = vim.api.nvim_create_augroup("NeotreeOnNewTab", { clear = true }),
  command = "Neotree",
})
