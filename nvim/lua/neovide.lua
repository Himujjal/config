local function mac_only_commands()
  if vim.fn.has("mac") == 0 then
    vim.g.neovide_input_macos_alt_is_meta = true
  end
end

local function get_title()
  -- get env variable named: `PWD`
  local pwd = vim.env.PWD

  -- get basename of `PWD`
  if pwd == nil then
    return "Neovide"
  end

  return vim.fs.basename(pwd)
end

if vim.g.neovide then
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

  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

  local opts = { noremap = true, silent = true }

  vim.keymap.set({ "n", "i" }, "<C-=>", function()
    ResizeGuiFont(1)
  end, opts)
  vim.keymap.set({ "n", "i" }, "<C-->", function()
    ResizeGuiFont(-1)
  end, opts)
  vim.keymap.set({ "n", "i" }, "<C-BS>", function()
    ResetGuiFont()
  end, opts)

  ResizeGuiFont = function(delta)
    vim.g.gui_font_size = vim.g.gui_font_size + delta
    RefreshGuiFont()
  end

  RefreshGuiFont = function()
    vim.opt.guifont = string.format("%s:h%s", vim.g.gui_font_face, vim.g.gui_font_size)
  end

  ResizeGuiFont = function(delta)
    vim.g.gui_font_size = vim.g.gui_font_size + delta
    RefreshGuiFont()
  end

  ResetGuiFont = function()
    vim.g.gui_font_size = vim.g.gui_font_default_size
    RefreshGuiFont()
  end

  -- Call function on startup to set default value
  ResetGuiFont()
  return ResetGuiFont
end
