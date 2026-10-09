-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- This file holds ONLY generic editor-level maps and custom (plugin-less) integrations.
-- Plugin-specific keymaps live in each spec's `keys` field under lua/plugins/**.

local buffers = require("modules.buffers")

local mappings = {
  n = {
    -- Buffer navigation
    ["}"] = {
      function()
        buffers.buf_nav(vim.v.count1)
      end,
      desc = "Next buffer",
    },
    ["{"] = {
      function()
        buffers.buf_nav(-vim.v.count1)
      end,
      desc = "Previous buffer",
    },
    ["<C-c>"] = { "<cmd>bdelete<cr>", desc = "Close the buffer" },
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = { buffers.buffer_close_picker, desc = "Pick to close" },

    -- Save / copy / replace
    ["zz"] = { "<cmd>w!<cr>", desc = "Save files" },
    ["<C-a>"] = { ":%y+<cr><cr>", desc = "Copy file content", silent = true },
    ["s"] = { "ciw", desc = "Replace the word under the cursor with the selected text" },

    -- Scrolling aliases
    ["<s-L>"] = { "<c-u>", desc = "Lazy" },
    ["<s-H>"] = { "<c-d>", desc = "Lazy" },

    -- Window navigation
    ["<C-h>"] = { "<C-w>h", desc = "Go to left window" },
    ["<C-j>"] = { "<C-w>j", desc = "Go to lower window" },
    ["<C-k>"] = { "<C-w>k", desc = "Go to upper window" },
    ["<C-l>"] = { "<C-w>l", desc = "Go to right window" },
    ["|"] = { "<Cmd>vsplit<CR>", "Vsplit current buffer" },
    ["\\"] = { "<Cmd>split<CR>", "Horizontal split current buffer" },

    ["<leader>L"] = { "<cmd>Lazy<cr>", desc = "Lazy" },

    -- Code actions / LSP (generic)
    ["<leader>l"] = { name = "Code Actions" },
    ["<leader>lf"] = { vim.lsp.buf.format, desc = "Format" },
    ["<leader>la"] = { vim.lsp.buf.code_action, desc = "Code Action" },
    ["<leader>ls"] = {
      function()
        vim.lsp.buf.document_symbol({})
      end,
      desc = "Symbols",
    },

    -- Kimish terminal (custom, plugin-less)
    ["<leader>k"] = { "<cmd>KimishToggle<CR>", desc = "Toggle Kimish Terminal Session" },
    ["<leader>ka"] = { "<cmd>KimishToggle<CR>", desc = "Toggle Kimish terminal (no thinking)", silent = true },
    ["<leader>kt"] = { "<cmd>KimishToggleThinking<CR>", desc = "Toggle Kimish terminal (with thinking)", silent = true },

    -- Yazi file explorer (custom, plugin-less)
    ["<leader>yz"] = { "<cmd>Yazi<CR>", desc = "Opens the yazi file explorer" },
  },

  -- visual-only keybindings
  v = {
    ["/"] = { [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], silent = true, desc = "Search in visual mode" },
    ["s"] = { "c", desc = "Replace the word under the cursor with the selected text" },

    -- Kimish: send visual selection
    ["<leader>ke"] = {
      function()
        -- Exit visual mode first to update marks
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
        -- Defer to allow marks to be set
        vim.defer_fn(function()
          require("modules.kimish").send_visual_selection()
        end, 10)
      end,
      desc = "Send visual selection to Kimish",
      silent = true,
    },
  },
}

-- Delete previous mapping (clear a LazyVim default before redefining)
pcall(vim.keymap.del, "n", "<leader>l")

for mode, maps in pairs(mappings) do
  for lhs, def in pairs(maps) do
    -- Skip entries that only label (a mapping group) with no lhs mapping
    if type(def) == "table" and def.name and def[1] == nil then
      goto continue
    end

    local rhs = def[1] or def
    local desc = def.desc or nil
    local opts = { desc = desc, noremap = true, silent = def.silent or false }

    LazyVim.safe_keymap_set(mode, lhs, rhs, opts)
    ::continue::
  end
end
