-- Bruno: API collection runner integration.

return {
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
}
