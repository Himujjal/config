-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set leader key (must be set before any keymaps are loaded)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw (vim's built-in file explorer) in favor of neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
