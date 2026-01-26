-- neotree config to make sidebar filenav sticky
-- across splits
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Track whether neo-tree should be visible
    vim.g.neo_tree_visible = false

    vim.api.nvim_create_autocmd("TabEnter", {
      callback = function()
        if vim.g.neo_tree_visible then
          vim.defer_fn(function()
            require("neo-tree.command").execute({ action = "show" })
          end, 0)
        end
      end,
    })

    -- Override the toggle to track state
    vim.keymap.set("n", "<leader>e", function()
      vim.g.neo_tree_visible = not vim.g.neo_tree_visible
      require("neo-tree.command").execute({ toggle = true })
    end, { desc = "Toggle Explorer" })

    return opts
  end,
}
