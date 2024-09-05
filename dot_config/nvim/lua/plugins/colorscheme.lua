-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  -- configure gruvbox theme
  {
    "ellisonleao/gruvbox.nvim",
    -- disable italics because i find them jarring in code files
    opts = {
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
      -- force very dark background for gruvbox; the default grey is too washed out.
      -- adapted from https://stackoverflow.com/a/75856730
      contrast = "hard",
      palette_overrides = {
        dark0_hard = "#000000",
      },
    },
  },
}
