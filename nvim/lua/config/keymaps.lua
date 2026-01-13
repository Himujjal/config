-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function buf_nav(step)
  local bufs = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and vim.bo[b].bufhidden == ""
  end, vim.api.nvim_list_bufs())

  if #bufs == 0 then
    return
  end

  local cur = vim.api.nvim_get_current_buf()
  local idx = 0
  for i, b in ipairs(bufs) do
    if b == cur then
      idx = i
      break
    end
  end

  idx = (idx + step - 1) % #bufs + 1
  vim.api.nvim_set_current_buf(bufs[idx])
end

local function buffer_close_picker()
  ---@diagnostic disable-next-line: param-type-mismatch
  local chosen = vim.fn.getbufinfo({ bufmodified = 0 })
  if #chosen == 0 then
    return
  end
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(chosen) do
    if b.bufnr ~= cur then
      vim.api.nvim_buf_delete(b.bufnr, { force = false })
    end
  end
end

local mappings = {
  n = {
    ["}"] = {
      function()
        buf_nav(vim.v.count1)
      end,
      desc = "Next buffer",
    },
    ["{"] = {
      function()
        buf_nav(-vim.v.count1)
      end,
      desc = "Previous buffer",
    },
    ["zz"] = { "<cmd>w!<cr>", desc = "Save files" },
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["s"] = { "ciw", desc = "Replace the word under the cursor with the selected text" },
    ["<Leader>bD"] = { buffer_close_picker, desc = "Pick to close" },
    ["<C-a>"] = { ":%y+<cr><cr>", desc = "Copy file content", silent = true },
    ["<leader>mp"] = { "<cmd>PeekOpen<cr>", desc = "Open markdown preview" },
    ["<C-c>"] = { "<cmd>bdelete<cr>", desc = "Close the buffer" },
    ["<s-L>"] = { "<c-u>", desc = "Lazy" },
    ["<s-H>"] = { "<c-d>", desc = "Lazy" },

    ["|"] = { "<Cmd>vsplit<CR>", "Vsplit current buffer" },
    ["\\"] = { "<Cmd>split<CR>", "Horizontal split current buffer" },

    ["<leader>L"] = { "<cmd>Lazy<cr>", desc = "Lazy" },

    -- formatting and code actions
    ["<leader>l"] = { name = "Code Actions" },
    ["<leader>lf"] = { vim.lsp.buf.format, desc = "Format" },
    ["<leader>la"] = { vim.lsp.buf.code_action, desc = "Code Action" },
    ["<leader>ls"] = {
      function()
        vim.lsp.buf.document_symbol({})
      end,
      desc = "Symbols",
    },

    -- Sidekick additions – normal-mode only unless otherwise noted
    ["<leader>a"] = { name = "AI Sidekick" },
    ["<leader>aa"] = {
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle CLI",
    },
    ["<leader>as"] = {
      function()
        require("sidekick.cli").select()
      end,
      desc = "Select CLI",
    },
    ["<leader>ad"] = {
      function()
        require("sidekick.cli").close()
      end,
      desc = "Detach a CLI Session",
    },
    ["<leader>af"] = {
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send File",
    },
    ["<leader>ap"] = {
      function()
        require("sidekick.cli").prompt()
      end,
      desc = "Sidekick Select Prompt",
    },
    ["<leader>ao"] = {
      function()
        require("sidekick.cli").toggle({ name = "opencode", focus = true })
      end,
      desc = "Sidekick Toggle OpenCode",
    },
  },
  v = {
    ["/"] = { [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], silent = true, desc = "Search in visual mode" },

    -- visual-only Sidekick maps
    ["<leader>at"] = {
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      desc = "Send This",
    },
    ["<leader>av"] = {
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      desc = "Send Visual Selection",
    },
    ["<leader>ap"] = {
      function()
        require("sidekick.cli").prompt()
      end,
      desc = "Sidekick Select Prompt",
    },
    ["s"] = { "c", desc = "Replace the word under the cursor with the selected text" },
  },
  i = {
    ["<C-l>"] = {
      function()
        LazyVim.cmp.actions.ai_accept()
      end,
      desc = "Close the buffer",
    },
  },
}

-- Delete previous mappings
vim.keymap.del("n", "<leader>l")

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
