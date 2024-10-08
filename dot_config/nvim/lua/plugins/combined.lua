return {
  {
    -- Configure commenting of blocks via leader key.
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
  {
    -- Configure string-completion via Tab, but *not* via Enter.
    -- via https://www.reddit.com/r/neovim/comments/10z5egh/comment/j8ahwu7/
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.completion = { completeopt = "menu,menuone,noinsert,noselect" }
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- they way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
