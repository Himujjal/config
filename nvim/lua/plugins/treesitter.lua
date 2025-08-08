-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "typescript",
      "javascript",
      "go",
      "rust",
      "json",
      "zig",
      "elixir",
      "markdown",
      "markdown_inline"
      -- add more arguments for adding more treesitter parsers
    },
  },
}
