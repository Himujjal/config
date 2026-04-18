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
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        ".",
        function()
          -- neo-tree set the cwd to the current file's directory under the cursor
          require("neo-tree").change_dir(vim.fn.expand("%:p:h"))
        end,
        desc = "Set neovim directory to current file",
      },
    },
  },
  {
    "romek-codes/bruno.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("bruno").setup({
        collection_paths = {
          { name = "Saanvi", path = "~/projects/saanvi/Saanvi/apps/server/saanvi-bruno-api" },
        },
        picker = "telescope",
        show_formatted_output = true,
        suppress_formatting_errors = false,
      })
    end,
  },
  ---@type LazySpec
  -- DISABLED: yazi.nvim - was causing confusion with multiple explorers
  -- {
  --   "mikavilpas/yazi.nvim",
  --   enabled = false,
  -- },

  -- Markdown preview
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  -- Render markdown in buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
