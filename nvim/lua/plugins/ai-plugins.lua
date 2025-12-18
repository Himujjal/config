return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "BufRead",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-l>",
          accept_word = "<C-k>",
          clear_suggestion = "<C-c>",
        },
        disable_keymaps = false, -- disables built in keymaps for more manual control
        log_level = "off",
      })
    end,
  },
}
