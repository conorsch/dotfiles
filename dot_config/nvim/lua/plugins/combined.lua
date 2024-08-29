return {
  {
    "numToStr/Comment.nvim",
    opts = {
      ---LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        ---Line-comment keymap. This works on visual "blocks", too,
        ---and will prefix all lines selected with the appropriate comment symbol.
        line = "#",
        ---Block-comment keymap. This will try to create a multiline comment,
        ---which isn't supported in all languages. Easier just to use a block IMO.
        block = "gb",
      },
    },
  },
}
