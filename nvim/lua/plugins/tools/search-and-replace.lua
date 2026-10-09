-- search-and-replace: buffer-wide search & replace UI.

return {
  {
    "mahyarmirrashed/search-and-replace.nvim",
    config = function()
      require("search-and-replace").setup()
    end,
  },
}
