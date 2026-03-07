-- Kimish terminal session management for Neovim
-- Opens a kimish session in a terminal buffer on the right side (1/3 width)
-- Buffer is unlisted so it doesn't appear in buffer tabs

local M = {}

local kimish_term_buf = nil
local kimish_term_win = nil

function M.toggle_kimish_session(opts)
  opts = opts or {}
  local with_thinking = opts.thinking or false

  -- If window exists and is valid, close it
  if kimish_term_win and vim.api.nvim_win_is_valid(kimish_term_win) then
    vim.api.nvim_win_close(kimish_term_win, true)
    kimish_term_win = nil
    return
  end

  -- Get project root (current working directory)
  local project_root = vim.fn.getcwd()

  -- If buffer doesn't exist or is invalid, create it
  if not kimish_term_buf or not vim.api.nvim_buf_is_valid(kimish_term_buf) then
    kimish_term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buflisted", false, { buf = kimish_term_buf })
    vim.api.nvim_set_option_value("bufhidden", "hide", { buf = kimish_term_buf })
  end

  -- Calculate width (1/3 of screen)
  local total_width = vim.api.nvim_get_option_value("columns", {})
  local term_width = math.max(math.floor(total_width / 3), 40)

  -- Open vertical split on the far right (botright ensures consistent position)
  vim.cmd("botright " .. term_width .. "vnew")
  kimish_term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(kimish_term_win, kimish_term_buf)
  
  -- Fix the width so it doesn't shift when entering/exiting
  vim.api.nvim_set_option_value("winfixwidth", true, { win = kimish_term_win })

  -- Enable text wrapping in the terminal window
  -- Note: wrap/linebreak work on the display; we also set a large pty width
  -- in jobstart so the process doesn't hard-wrap lines internally
  vim.api.nvim_set_option_value("wrap", true, { win = kimish_term_win })
  vim.api.nvim_set_option_value("linebreak", true, { win = kimish_term_win })
  vim.api.nvim_set_option_value("breakindent", true, { win = kimish_term_win })
  vim.api.nvim_set_option_value("showbreak", "↳ ", { win = kimish_term_win })

  -- Start terminal if not already running
  local term_chan = vim.b[kimish_term_buf].terminal_job_id
  if not term_chan then
    -- IMPORTANT: Must be in the terminal window when starting the job
    -- so it inherits the correct width for wrapping
    local prev_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(kimish_term_win)

    -- Build kimi command (use 'command kimi' to bypass shell alias)
    local kimish_cmd = "command kimi --yolo -w " .. vim.fn.shellescape(project_root)
    if not with_thinking then
      kimish_cmd = kimish_cmd .. " --no-thinking"
    end
    local kimish_args = { "sh", "-c", kimish_cmd }

    term_chan = vim.fn.jobstart(kimish_args, {
      term = true,
      pty = true,
      width = 9999, -- Large width so process doesn't hard-wrap lines
      height = vim.o.lines,
      on_exit = function()
        -- Close the window if it's still valid
        if kimish_term_win and vim.api.nvim_win_is_valid(kimish_term_win) then
          vim.api.nvim_win_close(kimish_term_win, true)
        end
        -- Delete the buffer if it's still valid
        if kimish_term_buf and vim.api.nvim_buf_is_valid(kimish_term_buf) then
          vim.api.nvim_buf_delete(kimish_term_buf, { force = true })
        end
        kimish_term_buf = nil
        kimish_term_win = nil
      end,
    })

    -- Restore previous window position
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_set_current_win(prev_win)
    end

    vim.b[kimish_term_buf].terminal_job_id = term_chan
  end

  -- Set up terminal-local keymaps for this buffer BEFORE entering insert mode
  -- This ensures keymaps are active when user starts typing
  M.setup_terminal_keymaps()

  -- Enter insert mode in terminal
  vim.cmd("startinsert")
end

-- Set up terminal-local keymaps for the kimish buffer
function M.setup_terminal_keymaps()
  if not kimish_term_buf or not vim.api.nvim_buf_is_valid(kimish_term_buf) then
    return
  end

  -- <C-h> to move to the left window (exit terminal mode first, then navigate)
  vim.api.nvim_buf_set_keymap(kimish_term_buf, "t", "<C-h>", "<C-\\><C-n><C-w>h", {
    noremap = true,
    silent = true,
    desc = "Move to left window from terminal",
  })
  -- Note: <C-l> is NOT mapped to allow terminal's clear-screen functionality
  -- <C-j> to move to the window below
  vim.api.nvim_buf_set_keymap(kimish_term_buf, "t", "<C-j>", "<C-\\><C-n><C-w>j", {
    noremap = true,
    silent = true,
    desc = "Move to window below from terminal",
  })
  -- <C-k> to move to the window above
  vim.api.nvim_buf_set_keymap(kimish_term_buf, "t", "<C-k>", "<C-\\><C-n><C-w>k", {
    noremap = true,
    silent = true,
    desc = "Move to window above from terminal",
  })
  -- Esc to exit to normal mode
  vim.api.nvim_buf_set_keymap(kimish_term_buf, "t", "<Esc>", "<C-\\><C-n>", {
    noremap = true,
    silent = true,
    desc = "Exit to normal mode from terminal",
  })
  -- Multi-line input keymaps for kimi terminal
  -- Note: <S-Enter> (Shift+Enter) is NOT distinguishable from Enter in most terminals.
  -- The terminal emulator sends the same bytes for both, so Neovim cannot differentiate them.
  -- Use Alt+Enter (<M-CR>) or <C-j> instead for reliable multi-line input.
  local function send_newline_no_submit()
    -- Send a literal newline character to the terminal job
    -- Use chan_send to directly inject input to the terminal process
    local term_chan = vim.b[kimish_term_buf].terminal_job_id
    if term_chan then
      vim.api.nvim_chan_send(term_chan, "\n")
    end
  end
  
  -- Alt+Enter (Meta+Enter) - works in most terminals
  vim.keymap.set("t", "<M-CR>", send_newline_no_submit, {
    buffer = kimish_term_buf,
    noremap = true,
    silent = true,
    desc = "Alt+Enter for new line in kimi",
  })
  
  -- Also map <M-Enter> variant
  vim.keymap.set("t", "<M-Enter>", send_newline_no_submit, {
    buffer = kimish_term_buf,
    noremap = true,
    silent = true,
    desc = "Alt+Enter for new line in kimi",
  })
  
  -- <C-j> is the most reliable - sends newline directly (same as Ctrl+J)
  vim.keymap.set("t", "<C-j>", function()
    local term_chan = vim.b[kimish_term_buf].terminal_job_id
    if term_chan then
      vim.api.nvim_chan_send(term_chan, "\n")
    end
  end, {
    buffer = kimish_term_buf,
    noremap = true,
    silent = true,
    desc = "Ctrl+J for new line in kimi",
  })
  
  -- Note: These may work in some terminal emulators that are configured to send different sequences
  -- for Shift+Enter vs regular Enter (e.g., iTerm2 can be configured this way)
  vim.keymap.set("t", "<S-CR>", send_newline_no_submit, {
    buffer = kimish_term_buf,
    noremap = true,
    silent = true,
    desc = "Shift+Enter for new line in kimi (terminal dependent)",
  })
end

-- Create user commands
vim.api.nvim_create_user_command("KimishToggle", function()
  M.toggle_kimish_session({ thinking = false })
end, { desc = "Toggle Kimish terminal session (no thinking)" })

vim.api.nvim_create_user_command("KimishToggleThinking", function()
  M.toggle_kimish_session({ thinking = true })
end, { desc = "Toggle Kimish terminal session (with thinking)" })

-- Autocommand to enter insert mode when kimish terminal buffer is active
vim.api.nvim_create_autocmd({ "TermEnter" }, {
  pattern = "*",
  callback = function()
    if kimish_term_buf and vim.api.nvim_buf_is_valid(kimish_term_buf) then
      local current_buf = vim.api.nvim_get_current_buf()
      if current_buf == kimish_term_buf then
        vim.cmd("startinsert")
      end
    end
  end,
  desc = "Auto-enter insert mode in kimish terminal",
})

-- Also enter insert mode when entering the kimi window from another window
vim.api.nvim_create_autocmd({ "WinEnter" }, {
  pattern = "*",
  callback = function()
    if kimish_term_buf and vim.api.nvim_buf_is_valid(kimish_term_buf) then
      local current_buf = vim.api.nvim_get_current_buf()
      if current_buf == kimish_term_buf then
        vim.cmd("startinsert")
      end
    end
  end,
  desc = "Auto-enter insert mode when entering kimi terminal window",
})

-- Function to send visual selection to kimish terminal
function M.send_visual_selection()
  -- Check if a kimish session is active (buffer exists and is valid)
  if not kimish_term_buf or not vim.api.nvim_buf_is_valid(kimish_term_buf) then
    vim.notify("No active Kimish session. Use <leader>ka or <leader>kt to open one first.", vim.log.levels.WARN)
    return
  end

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

  -- Ensure window is valid and visible
  if not kimish_term_win or not vim.api.nvim_win_is_valid(kimish_term_win) then
    -- Try to find an existing window with the buffer
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == kimish_term_buf then
        kimish_term_win = win
        break
      end
    end

    -- If still not found, open a new window
    if not kimish_term_win or not vim.api.nvim_win_is_valid(kimish_term_win) then
      local total_width = vim.api.nvim_get_option_value("columns", {})
      local term_width = math.floor(total_width / 3)
      vim.cmd("vsplit")
      kimish_term_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(kimish_term_win, kimish_term_buf)
      vim.api.nvim_win_set_width(kimish_term_win, term_width)
      -- Enable text wrapping in the terminal window
      vim.api.nvim_set_option_value("wrap", true, { win = kimish_term_win })
      vim.api.nvim_set_option_value("linebreak", true, { win = kimish_term_win })
      vim.api.nvim_set_option_value("breakindent", true, { win = kimish_term_win })
      vim.api.nvim_set_option_value("showbreak", "↳ ", { win = kimish_term_win })
    end
  end

  -- Get the terminal job ID
  local term_chan = vim.b[kimish_term_buf].terminal_job_id
  if not term_chan then
    vim.notify("Kimish terminal is not ready yet", vim.log.levels.WARN)
    return
  end

  -- Send the reference string to the terminal
  vim.api.nvim_chan_send(term_chan, ref_string)

  -- Also yank the reference to the default register for convenience
  vim.fn.setreg('"', ref_string)
  vim.fn.setreg("0", ref_string)

  -- Focus the kimish terminal window
  vim.api.nvim_set_current_win(kimish_term_win)
end

-- Global keymaps to toggle kimish
-- <leader>ka: kimish without thinking (yolo)
vim.keymap.set("n", "<leader>ka", ":KimishToggle<CR>", { desc = "Toggle Kimish terminal (no thinking)", silent = true })
-- <leader>kt: kimish with thinking (yolo)
vim.keymap.set("n", "<leader>kt", ":KimishToggleThinking<CR>", { desc = "Toggle Kimish terminal (with thinking)", silent = true })

-- Visual mode keymap to send selection to kimish
vim.keymap.set("v", "<leader>ke", function()
  -- Exit visual mode first to update marks
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  -- Defer to allow marks to be set
  vim.defer_fn(function()
    M.send_visual_selection()
  end, 10)
end, { desc = "Send visual selection to Kimish", silent = true })

-- Return the module for external access
return {}
