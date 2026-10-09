-- Neovide (GUI) specific settings and keymaps.
-- Only applies when running inside Neovide (vim.g.neovide is set).

local M = {}

local function mac_only_commands()
  if vim.fn.has("mac") == 0 then
    vim.g.neovide_input_macos_alt_is_meta = true
  end
end

local function get_title()
  -- get env variable named: `PWD`
  local pwd = vim.env.PWD
  if pwd == nil then
    return "Neovide"
  end
  return vim.fs.basename(pwd)
end

function M.setup()
  if not vim.g.neovide then
    return
  end

  mac_only_commands()
  vim.opt.title = true
  vim.opt.titlestring = get_title()

  vim.api.nvim_set_current_dir(vim.env.PWD)

  -- font family
  -- vim.opt.guifont = "FiraCode Nerd Font Mono:"
  vim.g.gui_font_face = "Fira Code Retina"
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.g.gui_font_default_size = 16
  vim.g.gui_font_size = vim.g.gui_font_default_size

  local function refresh_gui_font()
    vim.opt.guifont = string.format("%s:h%s", vim.g.gui_font_face, vim.g.gui_font_size)
  end

  local function resize_gui_font(delta)
    vim.g.gui_font_size = vim.g.gui_font_size + delta
    refresh_gui_font()
  end

  local function reset_gui_font()
    vim.g.gui_font_size = vim.g.gui_font_default_size
    refresh_gui_font()
  end

  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

  local opts = { noremap = true, silent = true }

  vim.keymap.set({ "n", "i" }, "<C-=>", function()
    resize_gui_font(1)
  end, opts)
  vim.keymap.set({ "n", "i" }, "<C-->", function()
    resize_gui_font(-1)
  end, opts)
  vim.keymap.set({ "n", "i" }, "<C-BS>", function()
    reset_gui_font()
  end, opts)

  -- Call function on startup to set default value
  reset_gui_font()
end

return M
