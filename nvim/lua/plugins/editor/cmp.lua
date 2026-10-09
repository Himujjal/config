return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.enabled = function()
        local disabled = false
        disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
        disabled = disabled or (vim.fn.reg_recording() ~= "")
        disabled = disabled or (vim.fn.reg_executing() ~= "")
        disabled = disabled or require("cmp.config.context").in_treesitter_capture("comment")
        disabled = disabled or (vim.bo.filetype == "markdown")
        return not disabled
      end
    end,
  },
}
