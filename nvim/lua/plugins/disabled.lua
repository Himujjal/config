-- Disable default plugins we don't want
return {
  -- Disable nvim-tree in favor of neo-tree
  { "nvim-tree/nvim-tree.lua", enabled = false },

  -- Disable snacks.nvim explorer (LazyVim's new default explorer)
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
  },
}
