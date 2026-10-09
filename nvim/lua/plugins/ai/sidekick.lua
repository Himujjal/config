-- Sidekick: terminal-based AI assistants (opencode, etc.) via zellij mux.

return {
  {
    "folke/sidekick.nvim",
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = "zellij",
          enabled = true,
        },
      },
    },
    keys = {
      { "<leader>a", group = "AI Sidekick" },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Select CLI",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        desc = "Sidekick Select Prompt",
      },
      {
        "<leader>ao",
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end,
        desc = "Sidekick Toggle OpenCode",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = "v",
        desc = "Send This",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = "v",
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = "v",
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
