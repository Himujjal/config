-- Tree-sitter utilities for Ekon

local M = {}

--- Install the tree-sitter parser for Ekon
--- Note: This just registers the config, use :TSInstall ekon to actually install
--- @return boolean success
function M.register_parser()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    vim.notify("nvim-treesitter is not installed", vim.log.levels.WARN)
    return false
  end

  local parser_config = parsers.get_parser_configs()

  -- Already registered
  if parser_config.ekon then
    return true
  end

  -- Register the parser config
  parser_config.ekon = {
    install_info = {
      url = vim.fn.expand("~/projects/ekon-zig/tree-sitter-ekon"),
      files = { "src/parser.c" },
      branch = "main",
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = "ekon",
  }

  return true
end

--- Get the syntax tree for the current buffer
--- @return table|nil tree The syntax tree
function M.get_tree()
  local bufnr = vim.api.nvim_get_current_buf()
  local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr, "ekon")

  if not has_parser then
    vim.notify("Ekon parser not available", vim.log.levels.WARN)
    return nil
  end

  return parser:parse()[1]
end

--- Get the root node of the syntax tree
--- @return table|nil node The root node
function M.get_root()
  local tree = M.get_tree()
  if not tree then
    return nil
  end

  return tree:root()
end

return M
