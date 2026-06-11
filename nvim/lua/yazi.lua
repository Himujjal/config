local M = {}

local yazi_buf = nil
local yazi_win = nil

function M.toggle_yazi()
  if yazi_win and vim.api.nvim_win_is_valid(yazi_win) then
    vim.api.nvim_win_close(yazi_win, true)
    yazi_win = nil
    return
  end

  if not yazi_buf or not vim.api.nvim_buf_is_valid(yazi_buf) then
    yazi_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buflisted", false, { buf = yazi_buf })
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  yazi_win = vim.api.nvim_open_win(yazi_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.fn.termopen("yazi", {
    cwd = vim.fn.expand("%:p:h") or vim.fn.getcwd(),
    on_exit = function()
      if yazi_win and vim.api.nvim_win_is_valid(yazi_win) then
        vim.api.nvim_win_close(yazi_win, true)
        yazi_win = nil
      end
    end,
  })
  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("Yazi", M.toggle_yazi, { desc = "Toggle Yazi file manager" })

return M
