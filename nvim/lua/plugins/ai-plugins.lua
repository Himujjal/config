-- Central hub for loading Neovim plugins that provide AI-assisted coding, completion, and chat capabilities.

return {
  {
    "supermaven-inc/supermaven-nvim",
    opts = function()
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"

      LazyVim.cmp.actions.ai_accept = function()
        local suggestion = require("supermaven-nvim.completion_preview")
        if suggestion.has_suggestion() then
          LazyVim.create_undo()
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end
      end
    end,
  },
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
  },
  {
    "robitx/gp.nvim",
    config = function()
      local system_prompt = require("gp.defaults").chat_system_prompt

      local deepseek_key = os.getenv("DEEPSEEK_API_KEY")

      local conf = {
        openai_api_key = os.getenv("OPENAI_API_KEY"),

        providers = {
          deepseek = {
            disable = false,
            endpoint = "https://api.deepseek.com/chat/completions",
            secret = deepseek_key,
          },
        },

        agents = {
          {
            provider = "deepseek",
            name = "Deepseek",
            chat = true,
            command = true,
            model = { model = "deepseek-v4-flash", stream = false },
            system_prompt = system_prompt,
          },
        },

        chat_shortcut_respond = { modes = { "n", "v", "x" }, shortcut = "<CR>" },
        chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
        chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
        chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },

        default_command_agent = "Deepseek",
        default_chat_agent = "Deepseek",
      }

      require("gp").setup(conf)
    end,
  },
}
