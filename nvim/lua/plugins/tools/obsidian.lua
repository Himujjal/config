-- Obsidian: note-taking integration for the personal vault.

return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    event = {
      "BufReadPre ~/documents/obsidian-personal/*.md",
      "BufNewFile ~/documents/obsidian-personal/*.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/documents/obsidian-personal",
        },
      },
    },
  },
}
