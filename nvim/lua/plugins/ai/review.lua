-- Code review annotations in codediff.nvim, optimized for AI feedback loops.
-- Add comments to diffs and export them as AI-ready markdown.
return {
  {
    "georgeguimaraes/review.nvim",
    version = "*",
    dependencies = {
      "esmuellert/codediff.nvim",
      "MunifTanjim/nui.nvim",
    },
    init = function()
      -- Release CDN stalls here, and the missing watcher binary would be
      -- downloaded synchronously on first :CodeDiff (freezing the UI).
      -- Fail fast to the polling fallback instead.
      vim.env.CODEDIFF_WATCHER_NO_AUTO_INSTALL = "1"
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>rr", "<cmd>Review<cr>", desc = "Review working tree" },
      { "<leader>rc", "<cmd>Review commits<cr>", desc = "Review commits" },
      { "<leader>rb", "<cmd>Review branch<cr>", desc = "Review branch" },
      { "<leader>rn", ":Review note<cr>", mode = { "n", "v" }, desc = "Review: note here" },
      { "<leader>re", "<cmd>Review edit<cr>", desc = "Review: edit comment" },
      { "<leader>rd", "<cmd>Review delete<cr>", desc = "Review: delete comment" },
      { "<leader>rx", "<cmd>Review export<cr>", desc = "Review: export" },
    },
    opts = {},
  },
}
