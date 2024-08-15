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
