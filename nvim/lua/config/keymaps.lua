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
        sidekick.toggle()
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

    -- GP.nvim Chat commands
    ["<C-g>c"] = { "<cmd>GpChatNew<cr>", desc = "GPT prompt New Chat" },
    ["<C-g>t"] = { "<cmd>GpChatToggle<cr>", desc = "GPT prompt Toggle Chat" },
    ["<C-g>f"] = { "<cmd>GpChatFinder<cr>", desc = "GPT prompt Chat Finder" },

    ["<C-g><C-x>"] = { "<cmd>GpChatNew split<cr>", desc = "GPT prompt New Chat split" },
    ["<C-g><C-v>"] = { "<cmd>GpChatNew vsplit<cr>", desc = "GPT prompt New Chat vsplit" },
    ["<C-g><C-t>"] = { "<cmd>GpChatNew tabnew<cr>", desc = "GPT prompt New Chat tabnew" },

    -- GP.nvim Prompt commands
    ["<C-g>r"] = { "<cmd>GpRewrite<cr>", desc = "GPT prompt Inline Rewrite" },
    ["<C-g>a"] = { "<cmd>GpAppend<cr>", desc = "GPT prompt Append (after)" },
    ["<C-g>b"] = { "<cmd>GpPrepend<cr>", desc = "GPT prompt Prepend (before)" },

    ["<C-g>gp"] = { "<cmd>GpPopup<cr>", desc = "GPT prompt Popup" },
    ["<C-g>ge"] = { "<cmd>GpEnew<cr>", desc = "GPT prompt GpEnew" },
    ["<C-g>gn"] = { "<cmd>GpNew<cr>", desc = "GPT prompt GpNew" },
    ["<C-g>gv"] = { "<cmd>GpVnew<cr>", desc = "GPT prompt GpVnew" },
    ["<C-g>gt"] = { "<cmd>GpTabnew<cr>", desc = "GPT prompt GpTabnew" },

    ["<C-g>x"] = { "<cmd>GpContext<cr>", desc = "GPT prompt Toggle Context" },

    -- GP.nvim Global commands (also in other modes)
    ["<C-g>n"] = { "<cmd>GpNextAgent<cr>", desc = "GPT prompt Next Agent" },
    ["<C-g>l"] = { "<cmd>GpSelectAgent<cr>", desc = "GPT prompt Select Agent" },
  },

  -- visual-only keybindings
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

    ["<C-g>c"] = { ":<C-u>'<,'>GpChatNew<cr>", desc = "GPT prompt Visual Chat New" },
    ["<C-g>p"] = { ":<C-u>'<,'>GpChatPaste<cr>", desc = "GPT prompt Visual Chat Paste" },
    ["<C-g>t"] = { ":<C-u>'<,'>GpChatToggle<cr>", desc = "GPT prompt Visual Toggle Chat" },

    ["<C-g><C-x>"] = { ":<C-u>'<,'>GpChatNew split<cr>", desc = "GPT prompt Visual Chat New split" },
    ["<C-g><C-v>"] = { ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "GPT prompt Visual Chat New vsplit" },
    ["<C-g><C-t>"] = { ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "GPT prompt Visual Chat New tabnew" },

    -- GP.nvim Visual Prompt commands
    ["<C-g>r"] = { ":<C-u>'<,'>GpRewrite<cr>", desc = "GPT prompt Visual Rewrite" },
    ["<C-g>a"] = { ":<C-u>'<,'>GpAppend<cr>", desc = "GPT prompt Visual Append (after)" },
    ["<C-g>b"] = { ":<C-u>'<,'>GpPrepend<cr>", desc = "GPT prompt Visual Prepend (before)" },
    ["<C-g>i"] = { ":<C-u>'<,'>GpImplement<cr>", desc = "GPT prompt Implement selection" },

    ["<C-g>gp"] = { ":<C-u>'<,'>GpPopup<cr>", desc = "GPT prompt Visual Popup" },
    ["<C-g>ge"] = { ":<C-u>'<,'>GpEnew<cr>", desc = "GPT prompt Visual GpEnew" },
    ["<C-g>gn"] = { ":<C-u>'<,'>GpNew<cr>", desc = "GPT prompt Visual GpNew" },
    ["<C-g>gv"] = { ":<C-u>'<,'>GpVnew<cr>", desc = "GPT prompt Visual GpVnew" },
    ["<C-g>gt"] = { ":<C-u>'<,'>GpTabnew<cr>", desc = "GPT prompt Visual GpTabnew" },

    ["<C-g>x"] = { ":<C-u>'<,'>GpContext<cr>", desc = "GPT prompt Visual Toggle Context" },

    -- GP.nvim Global commands (also in other modes)
    ["<C-g>s"] = { "<cmd>GpStop<cr>", desc = "GPT prompt Stop" },
    ["<C-g>n"] = { "<cmd>GpNextAgent<cr>", desc = "GPT prompt Next Agent" },
    ["<C-g>l"] = { "<cmd>GpSelectAgent<cr>", desc = "GPT prompt Select Agent" },
  },

  -- insert-mode keybindings
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

--
-- local function keymapOptions(desc)
--   return {
--     noremap = true,
--     silent = true,
--     nowait = true,
--     desc = "GPT prompt " .. desc,
--   }
-- end
--
-- -- Chat commands
-- vim.keymap.set({ "n", "i" }, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
-- vim.keymap.set({ "n", "i" }, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
-- vim.keymap.set({ "n", "i" }, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))
--
-- vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Visual Chat New"))
-- vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
-- vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))
--
-- vim.keymap.set({ "n", "i" }, "<C-g><C-x>", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
-- vim.keymap.set({ "n", "i" }, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
-- vim.keymap.set({ "n", "i" }, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))
--
-- vim.keymap.set("v", "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Visual Chat New split"))
-- vim.keymap.set("v", "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Chat New vsplit"))
-- vim.keymap.set("v", "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Visual Chat New tabnew"))
--
-- -- Prompt commands
-- vim.keymap.set({ "n", "i" }, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
-- vim.keymap.set({ "n", "i" }, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
-- vim.keymap.set({ "n", "i" }, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))
--
-- vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
-- vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
-- vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
-- vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))
--
-- vim.keymap.set({ "n", "i" }, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
-- vim.keymap.set({ "n", "i" }, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
-- vim.keymap.set({ "n", "i" }, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
-- vim.keymap.set({ "n", "i" }, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
-- vim.keymap.set({ "n", "i" }, "<C-g>gt", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))
--
-- vim.keymap.set("v", "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
-- vim.keymap.set("v", "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
-- vim.keymap.set("v", "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
-- vim.keymap.set("v", "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))
-- vim.keymap.set("v", "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("Visual GpTabnew"))
--
-- vim.keymap.set({ "n", "i" }, "<C-g>x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
-- vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))
--
-- vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>s", "<cmd>GpStop<cr>", keymapOptions("Stop"))
-- vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>n", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))
-- vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>l", "<cmd>GpSelectAgent<cr>", keymapOptions("Select Agent"))
--
-- -- optional Whisper commands with prefix <C-g>w
-- vim.keymap.set({ "n", "i" }, "<C-g>ww", "<cmd>GpWhisper<cr>", keymapOptions("Whisper"))
-- vim.keymap.set("v", "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", keymapOptions("Visual Whisper"))
--
-- vim.keymap.set({ "n", "i" }, "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", keymapOptions("Whisper Inline Rewrite"))
-- vim.keymap.set({ "n", "i" }, "<C-g>wa", "<cmd>GpWhisperAppend<cr>", keymapOptions("Whisper Append (after)"))
-- vim.keymap.set({ "n", "i" }, "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", keymapOptions("Whisper Prepend (before) "))
--
-- vim.keymap.set("v", "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", keymapOptions("Visual Whisper Rewrite"))
-- vim.keymap.set("v", "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", keymapOptions("Visual Whisper Append (after)"))
-- vim.keymap.set("v", "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", keymapOptions("Visual Whisper Prepend (before)"))
--
-- vim.keymap.set({ "n", "i" }, "<C-g>wp", "<cmd>GpWhisperPopup<cr>", keymapOptions("Whisper Popup"))
-- vim.keymap.set({ "n", "i" }, "<C-g>we", "<cmd>GpWhisperEnew<cr>", keymapOptions("Whisper Enew"))
-- vim.keymap.set({ "n", "i" }, "<C-g>wn", "<cmd>GpWhisperNew<cr>", keymapOptions("Whisper New"))
-- vim.keymap.set({ "n", "i" }, "<C-g>wv", "<cmd>GpWhisperVnew<cr>", keymapOptions("Whisper Vnew"))
-- vim.keymap.set({ "n", "i" }, "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", keymapOptions("Whisper Tabnew"))
--
-- vim.keymap.set("v", "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", keymapOptions("Visual Whisper Popup"))
-- vim.keymap.set("v", "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", keymapOptions("Visual Whisper Enew"))
-- vim.keymap.set("v", "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", keymapOptions("Visual Whisper New"))
-- vim.keymap.set("v", "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", keymapOptions("Visual Whisper Vnew"))
-- vim.keymap.set("v", "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", keymapOptions("Visual Whisper Tabnew"))
