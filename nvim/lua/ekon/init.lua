-- Ekon language support utilities for Neovim
-- This module provides helper functions for working with Ekon files

local M = {}

--- Check if the tree-sitter parser for Ekon is installed
--- @return boolean
function M.is_parser_installed()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end

  local parser_config = parsers.get_parser_configs()
  if not parser_config.ekon then
    return false
  end

  local has_parser, _ = pcall(vim.treesitter.get_parser, 0, "ekon")
  return has_parser
end

--- Get the Ekon parser info
--- @return table|nil
function M.get_parser_info()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return nil
  end

  return parsers.get_parser_configs().ekon
end

--- Format an Ekon buffer (placeholder for future formatter)
function M.format()
  vim.notify("Ekon formatter not yet implemented", vim.log.levels.WARN)
end

--- Validate an Ekon buffer (placeholder for future LSP)
function M.validate()
  vim.notify("Ekon LSP not yet implemented", vim.log.levels.WARN)
end

return M
