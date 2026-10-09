-- Buffer navigation and management helpers.

local M = {}

function M.buf_nav(step)
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

function M.buffer_close_picker()
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

return M
