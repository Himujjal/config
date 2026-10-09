-- Supermaven: AI code completion with cmp integration.

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
    keys = {
      {
        "<C-l>",
        function()
          LazyVim.cmp.actions.ai_accept()
        end,
        mode = "i",
        desc = "Accept AI suggestion",
      },
    },
  },
}
