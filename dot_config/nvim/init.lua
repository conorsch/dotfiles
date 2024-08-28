-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Colorschemes are set in `~/.config/nvim/plugins/colorscheme.lua`.
-- Set colorscheme. Reads from `~/.config/nvim/colors/*`.
-- vim.cmd("colorscheme tokyonight")
-- vim.cmd("colorscheme gruvbox")
-- vim.opt.termguicolors = true

-- The "acidcupcake" theme was copied wholesale from the vim colorscheme.
-- For reasons I don't understand, the colorscheme subtly changes
-- after Rust LSP finishes initializing, which is jarring.
-- vim.cmd("colorscheme acidcupcake")
