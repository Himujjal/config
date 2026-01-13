local theme = {
  rose_pine = {
    "rose-pine/neovim",
    name = "rose-pine",
  },

  tokyonight = {
    "tokyonight.nvim",
    opts = {
      style = "moon",
    },
  },
  transparent_plugin = {
    "xiyaowong/transparent.nvim",
    opts = function()
      vim.g.transaprent_enabled = true
      return {}
    end,
  },
}

local function only_neovim_plugin(plugin)
  if vim.g.neovide then
    return {}
  else
    return plugin
  end
end

return {
  theme.rose_pine,
  theme.tokyonight,
  only_neovim_plugin(theme.transparent_plugin),
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
