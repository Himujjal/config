local M = {}

function M.load()
  local env_file = vim.fn.expand("~/.config/nvim/.env")

  if vim.fn.filereadable(env_file) == 1 then
    local content = vim.fn.readfile(env_file)
    local loaded_count = 0
    for _, line in ipairs(content) do
      local key, value = line:match("^([^=]+)=(.+)$")
      if key and value and value ~= "" then
        vim.fn.setenv(key, value)
        loaded_count = loaded_count + 1
      end
    end
  else
    vim.notify("[dotenv] .env file not found, using shell environment", vim.log.levels.WARN)
  end
end

return M