-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- This file holds ONLY global autocmds and filetype associations.
-- Feature-specific autocmds live with their plugin spec under lua/plugins/**.

-- Open neo-tree on startup (right side)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only open neo-tree if no file was specified on the command line
    if vim.fn.argc() == 0 then
      vim.cmd("Neotree show right")
    end
  end,
})

-- Global filetype associations
vim.filetype.add({
  extension = {
    smd = "markdown",
    shtml = "html",
    ztl = "html",
  },
})
