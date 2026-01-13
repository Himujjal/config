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
  {
    "mikavilpas/yazi.nvim",
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>y",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Yazi!",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      -- {
      --   "<c-up>",
      --   "<cmd>Yazi toggle<cr>",
      --   desc = "Resume the last yazi session",
      -- },
    },
    ---@type YaziConfig | {}
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<s-/>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 0
    end,
  },

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
}
