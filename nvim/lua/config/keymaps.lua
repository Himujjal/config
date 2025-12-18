-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- `zz` for saving
--
--
local function buf_nav(step)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.cmd(string.format("%dbuffer", vim.fn.bufnr("#") + step))
end

local function new_file()
  vim.ui.input({ prompt = "New file: ", completion = "file" }, function(name)
    if name and name ~= "" then
      vim.cmd("edit " .. name)
    end
  end)
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
    ["<C-,>"] = { "<cmd>Neotree toggle<cr>", desc = "Toggle NvimTree" },
    ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<Leader>b"] = { name = "Buffers" },
    ["<C-g>"] = { name = "Gp.nvim commands" },
    ["<C-g><C-g>"] = { ":GpChatToggle vsplit<cr>", desc = "Toggle Chat (Normal)" },
    ["<C-g>r"] = { ":GpRewrite<cr>", desc = "Inline Assist (Rewrite)" },
    ["<C-g>R"] = { ":GpWhisperRewrite<cr>", desc = "Whisper Inline Assist" },
    ["<C-g>w"] = { ":GpWhisper<cr>", desc = "Whisper Inline Assist" },
    ["<C-g>a"] = { ":GpAppend<cr>", desc = "Append" },
    ["<C-g>A"] = { ":GpWhisperAppend<cr>", desc = "Whisper Append" },
    ["<leader>aC"] = { "<cmd>AvanteClear<cr>", desc = "Clear Avante Chat Context" },
    ["<C-a>"] = { ":%y+<cr><cr>", desc = "Copy file content", silent = true },
    ["<leader>mp"] = { "<cmd>PeekOpen<cr>", desc = "Open markdown preview" },
    ["<leader>cc"] = { "<cmd>bdelete<cr>", desc = "Close the buffer" },
  },
  v = {
    ["/"] = { [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], silent = true, desc = "Search in visual mode" },
  },
  i = {
    ["<C-l>"] = { "<cmd>call augment#Accept()<cr>", desc = "Accept suggestion" },
  },
}

for mode, maps in pairs(mappings) do
  for lhs, def in pairs(maps) do
    -- Skip entries that only label (a mapping group) with no lhs mapping
    if type(def) == "table" and def.name and def[1] == nil then
      goto continue
    end

    local rhs = def[1] or def
    local desc = def.desc or nil
    local opts = { desc = desc, noremap = true, silent = def.silent or false }

    vim.keymap.set(mode, lhs, rhs, opts)
    ::continue::
  end
end
