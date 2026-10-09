-- Peek: markdown preview via Deno.

return {
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    keys = {
      { "<leader>mp", "<cmd>PeekOpen<cr>", desc = "Open markdown preview" },
    },
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
}
