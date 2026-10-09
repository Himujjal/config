-- GP.nvim: AI chat/rewrite commands (Deepseek + OpenAI providers).
-- All <C-g> keymaps live here, co-located with the plugin.

local function gp_keys()
  -- normal-mode bindings
  local n = {
    { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
    { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
    { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
    { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
    { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
    { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
    { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
    { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
    { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
    { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
    { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
    { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
    { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
    { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
    { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle Context" },
    { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
    { "<C-g>l", "<cmd>GpSelectAgent<cr>", desc = "Select Agent" },
  }
  -- visual-mode bindings
  local v = {
    { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New" },
    { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste" },
    { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat" },
    { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "Visual Chat New split" },
    { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "Visual Chat New vsplit" },
    { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "Visual Chat New tabnew" },
    { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite" },
    { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)" },
    { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)" },
    { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
    { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup" },
    { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew" },
    { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew" },
    { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew" },
    { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew" },
    { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual Toggle Context" },
    { "<C-g>s", "<cmd>GpStop<cr>", desc = "Stop" },
    { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
    { "<C-g>l", "<cmd>GpSelectAgent<cr>", desc = "Select Agent" },
  }
  for _, m in ipairs(v) do
    m.mode = "v"
  end
  return vim.list_extend(n, v)
end

return {
  {
    "robitx/gp.nvim",
    keys = gp_keys(),
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
