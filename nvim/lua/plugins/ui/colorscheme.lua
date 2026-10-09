-- Colorschemes and appearance.
-- The active colorscheme is set via the LazyVim `colorscheme` opt at the bottom.

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
      vim.g.transparent_enabled = true
      return {}
    end,
  },
}

-- transparent.nvim conflicts with Neovide's compositor, so skip it there.
local function except_neovide(plugin)
  if vim.g.neovide then
    return {}
  else
    return plugin
  end
end

return {
  theme.rose_pine,
  theme.tokyonight,
  except_neovide(theme.transparent_plugin),
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
