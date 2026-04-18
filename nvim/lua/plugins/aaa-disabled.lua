return {
  -- Disable nvim-tree in favor of neo-tree
  { "nvim-tree/nvim-tree.lua", enabled = false },

  -- Override LazyVim's snacks.nvim config to disable explorer completely
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Disable the explorer module completely
      opts.explorer = { enabled = false }
      -- Also disable picker explorer source if configured
      if opts.picker and opts.picker.sources then
        opts.picker.sources.explorer = nil
      end
      return opts
    end,
    -- Override LazyVim's default <leader>e keymaps to prevent conflicts with neo-tree
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
