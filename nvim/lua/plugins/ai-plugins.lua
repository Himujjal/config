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

      -- Check all environment variables
      local deepseek_key = os.getenv("DEEPSEEK_API_KEY")
      local cerebras_key = os.getenv("CEREBRAS_API_KEY")
      local groq_key = os.getenv("GROQ_API_KEY")

      local conf = {
        providers = {
          deepseek = {
            disable = false,
            endpoint = "https://api.deepseek.com/chat/completions",
            secret = deepseek_key,
          },
          cerebras = {
            disable = false,
            endpoint = "https://api.cerebras.ai/v1/chat/completions",
            secret = cerebras_key,
          },
          groq = {
            disable = false,
            endpoint = "https://api.groq.com/openai/v1/chat/completions",
            secret = groq_key,
          },
        },

        agents = {
          {
            name = "Deepseek",
            provider = "deepseek",
            chat = true,
            command = true,
            model = { model = "deepseek-reasoner", stream = false },
            system_prompt = system_prompt,
          },
          {
            name = "Kimi",
            provider = "groq",
            chat = true,
            command = true,
            model = { model = "moonshotai/kimi-k2-instruct-0905" },
            system_prompt = system_prompt,
          },
          {
            name = "GLM",
            provider = "cerebras",
            chat = true,
            command = true,
            model = { model = "zai-glm-4.7", stream = false },
            system_prompt = system_prompt,
          },
        },

        chat_shortcut_respond = { modes = { "n", "v", "x" }, shortcut = "<CR>" },
        chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
        chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
        chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },

        default_command_agent = "Kimi",
        default_chat_agent = "Kimi",
      }

      require("gp").setup(conf)
    end,
  },
}
