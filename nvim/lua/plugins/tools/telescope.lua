-- Telescope: fuzzy finder (provided by LazyVim; config anchor here).

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>fw",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
    },
  },
}
