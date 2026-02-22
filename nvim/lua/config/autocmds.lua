-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Set ek filetype to use TypeScript syntax highlighting but prevent LSP
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.ek",
  callback = function()
    vim.bo.filetype = "typescript"
    -- Disable LSP for this buffer
    vim.bo.omnifunc = ""
    vim.bo.tagfunc = ""
    vim.bo.formatexpr = ""
  end,
})

-- Disable LSP for .ek files by stopping clients after a short delay
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname:match("%.ek$") then
      -- Use vim.schedule to avoid race conditions
      vim.schedule(function()
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        for _, client in ipairs(clients) do
          vim.lsp.buf_detach_client(args.buf, client.id)
        end
      end)
    end
  end,
})
