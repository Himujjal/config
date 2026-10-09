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

--- Manually compile and install the Ekon parser from local source.
--- Source is expected at ~/projects/ekon-zig/tree-sitter-ekon.
--- @return boolean success
function M.install_parser()
  local parser_src = vim.fn.expand("~/projects/ekon-zig/tree-sitter-ekon")
  local cc = vim.fn.getenv("CC") or "gcc"

  -- Check if source exists
  if vim.fn.isdirectory(parser_src) == 0 then
    vim.notify("Ekon parser source not found at: " .. parser_src, vim.log.levels.ERROR)
    return false
  end

  -- Check if parser.c exists
  local parser_c = parser_src .. "/src/parser.c"
  if vim.fn.filereadable(parser_c) == 0 then
    vim.notify("parser.c not found. Run 'tree-sitter generate' first.", vim.log.levels.ERROR)
    return false
  end

  -- Define destinations
  local parser_dest_nvim = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/ekon.so"
  local parser_dest_site = vim.fn.stdpath("data") .. "/site/parser/ekon.so"
  local queries_dest_nvim = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/queries/ekon"
  local queries_dest_site = vim.fn.stdpath("data") .. "/site/queries/ekon"

  -- Compile the parser
  local cmd = {
    cc,
    "-shared",
    "-fPIC",
    "-g",
    "-O2",
    "-I" .. parser_src .. "/src",
    parser_c,
    "-o",
    parser_dest_nvim,
  }

  vim.notify("Compiling Ekon parser...", vim.log.levels.INFO)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to compile Ekon parser:\n" .. output, vim.log.levels.ERROR)
    return false
  end

  -- Copy to site parser directory (needed for runtime path)
  vim.fn.mkdir(vim.fn.stdpath("data") .. "/site/parser", "p")
  vim.fn.system({ "cp", parser_dest_nvim, parser_dest_site })

  -- Copy queries to both locations
  local queries_src = vim.fn.expand("~/projects/ekon-zig/tree-sitter-ekon/queries")
  if vim.fn.isdirectory(queries_src) == 1 then
    vim.fn.mkdir(queries_dest_nvim, "p")
    vim.fn.mkdir(queries_dest_site, "p")
    for _, file in ipairs(vim.fn.glob(queries_src .. "/*.scm", false, true)) do
      vim.fn.system({ "cp", file, queries_dest_nvim .. "/" })
      vim.fn.system({ "cp", file, queries_dest_site .. "/" })
    end
  end

  -- Create parser-info file
  local info_dest = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser-info/ekon.revision"
  vim.fn.mkdir(vim.fn.fnamemodify(info_dest, ":h"), "p")
  local info_file = io.open(info_dest, "w")
  if info_file then
    info_file:write("local")
    info_file:close()
  end

  vim.notify("Ekon parser installed successfully!", vim.log.levels.INFO)

  -- Reload buffer to apply highlighting
  vim.cmd("edit!")
  return true
end

return M
