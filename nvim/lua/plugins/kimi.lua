-- Kimi terminal session management for Neovim
-- Opens a kimi session in a terminal buffer on the right side (1/4 width)
-- Buffer is unlisted so it doesn't appear in buffer tabs

local M = {}

local kimi_term_buf = nil
local kimi_term_win = nil

function M.toggle_kimi_session()
  -- If window exists and is valid, close it
  if kimi_term_win and vim.api.nvim_win_is_valid(kimi_term_win) then
    vim.api.nvim_win_close(kimi_term_win, true)
    kimi_term_win = nil
    return
  end

  -- Get project root (current working directory)
  local project_root = vim.fn.getcwd()

  -- If buffer doesn't exist or is invalid, create it
  if not kimi_term_buf or not vim.api.nvim_buf_is_valid(kimi_term_buf) then
    kimi_term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buflisted", false, { buf = kimi_term_buf })
    vim.api.nvim_set_option_value("bufhidden", "hide", { buf = kimi_term_buf })
  end

  -- Calculate width (1/4 of screen)
  local total_width = vim.api.nvim_get_option_value("columns", {})
  local term_width = math.floor(total_width / 4)

  -- Open vertical split on the right
  vim.cmd("vsplit")
  kimi_term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(kimi_term_win, kimi_term_buf)
  vim.api.nvim_win_set_width(kimi_term_win, term_width)

  -- Enable text wrapping in the terminal window
  vim.api.nvim_set_option_value("wrap", true, { win = kimi_term_win })
  vim.api.nvim_set_option_value("linebreak", true, { win = kimi_term_win })

  -- Start terminal if not already running
  local term_chan = vim.b[kimi_term_buf].terminal_job_id
  if not term_chan then
    vim.fn.termopen("kimi --yolo -w " .. vim.fn.shellescape(project_root), {
      on_exit = function()
        -- Close the window if it's still valid
        if kimi_term_win and vim.api.nvim_win_is_valid(kimi_term_win) then
          vim.api.nvim_win_close(kimi_term_win, true)
        end
        -- Delete the buffer if it's still valid
        if kimi_term_buf and vim.api.nvim_buf_is_valid(kimi_term_buf) then
          vim.api.nvim_buf_delete(kimi_term_buf, { force = true })
        end
        kimi_term_buf = nil
        kimi_term_win = nil
      end,
    })
  end

  -- Enter insert mode in terminal
  vim.cmd("startinsert")
end

-- Create user command
vim.api.nvim_create_user_command("KimiToggle", function()
  M.toggle_kimi_session()

  -- Set up terminal-local keymaps
  -- <C-h> to move to the left buffer (window)
  vim.api.nvim_buf_set_keymap(kimi_term_buf, "t", "<C-h>", "<C-\\><C-n><C-w>h", {
    noremap = true,
    silent = true,
    desc = "Move to left window from terminal",
  })
end, { desc = "Toggle Kimi terminal session" })

-- Autocommand to enter insert mode when kimi terminal buffer is active
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    if kimi_term_buf and vim.api.nvim_buf_is_valid(kimi_term_buf) then
      local current_buf = vim.api.nvim_get_current_buf()
      if current_buf == kimi_term_buf then
        vim.cmd("startinsert")
      end
    end
  end,
  desc = "Auto-enter insert mode in kimi terminal",
})

-- Function to send visual selection to kimi terminal
function M.send_visual_selection()
  -- Get visual selection range
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Get current file name (relative to cwd)
  local file_name = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  if file_name == "" then
    file_name = "[untitled]"
  end

  -- Construct the reference string: @file L<start>:L<end>
  local ref_string = string.format(" @%s L%d:L%d ", file_name, start_line, end_line)

  -- Ensure kimi terminal is open
  if not kimi_term_buf or not vim.api.nvim_buf_is_valid(kimi_term_buf) then
    M.toggle_kimi_session()
  end

  -- Ensure window is valid and visible
  if not kimi_term_win or not vim.api.nvim_win_is_valid(kimi_term_win) then
    -- Try to find an existing window with the buffer
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == kimi_term_buf then
        kimi_term_win = win
        break
      end
    end

    -- If still not found, open a new window
    if not kimi_term_win or not vim.api.nvim_win_is_valid(kimi_term_win) then
      local total_width = vim.api.nvim_get_option_value("columns", {})
      local term_width = math.floor(total_width / 4)
      vim.cmd("vsplit")
      kimi_term_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(kimi_term_win, kimi_term_buf)
      vim.api.nvim_win_set_width(kimi_term_win, term_width)
      -- Enable text wrapping in the terminal window
      vim.api.nvim_set_option_value("wrap", true, { win = kimi_term_win })
      vim.api.nvim_set_option_value("linebreak", true, { win = kimi_term_win })
    end
  end

  -- Get the terminal job ID
  local term_chan = vim.b[kimi_term_buf].terminal_job_id
  if not term_chan then
    vim.notify("Kimi terminal is not ready yet", vim.log.levels.WARN)
    return
  end

  -- Send the reference string to the terminal
  vim.api.nvim_chan_send(term_chan, ref_string)

  -- Also yank the reference to the default register for convenience
  vim.fn.setreg('"', ref_string)
  vim.fn.setreg("0", ref_string)

  -- Focus the kimi terminal window
  vim.api.nvim_set_current_win(kimi_term_win)

  vim.notify("Sent to kimi: " .. ref_string, vim.log.levels.INFO)
end

-- Global keymap to toggle kimi
vim.keymap.set("n", "<leader>kt", ":KimiToggle<CR>", { desc = "Toggle Kimi terminal", silent = true })

-- Visual mode keymap to send selection to kimi
vim.keymap.set("v", "<leader>ke", function()
  -- Exit visual mode first to update marks
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  -- Defer to allow marks to be set
  vim.defer_fn(function()
    M.send_visual_selection()
  end, 10)
end, { desc = "Send visual selection to Kimi", silent = true })

-- Return the module for external access
return {}
