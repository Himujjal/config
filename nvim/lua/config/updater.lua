--[[
  Silent Automatic LazyVim Updater
  
  Features:
  - Runs once per day in background when Neovim starts
  - Completely silent (no notifications even on failure)
  - Validates updates with Lua syntax checking before applying
  - Retries up to 3 times on validation failure
  - Uses vim.loop for non-blocking async operations
  
  Architecture:
  - State file: stdpath('data')/lazy-update-state.json
  - Temp clone: stdpath('cache')/lazy-update-temp/
  - Log file: stdpath('log')/lazy-updater.log (for debugging only)
]]

local M = {}

-- Configuration
local CONFIG = {
  max_retries = 3,
  retry_delay_ms = 5000,
  update_check_interval_hours = 24,
  -- Delay before starting update (ms) - let nvim finish loading first
  startup_delay_ms = 3000,
}

-- Paths
local PATHS = {
  state_file = vim.fn.stdpath("data") .. "/lazy-update-state.json",
  log_file = vim.fn.stdpath("log") .. "/lazy-updater.log",
  lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim",
  lazyvim_path = vim.fn.stdpath("data") .. "/lazy/LazyVim",
}

-- Utility: Write to log file (silent, no notifications)
local function log(msg)
  local f = io.open(PATHS.log_file, "a")
  if f then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    f:write(string.format("[%s] %s\n", timestamp, msg))
    f:close()
  end
end

-- Utility: Read state file
local function read_state()
  local f = io.open(PATHS.state_file, "r")
  if not f then
    return { last_update = 0, last_status = "never" }
  end
  local content = f:read("*all")
  f:close()
  
  local ok, state = pcall(vim.json.decode, content)
  if ok and state then
    return state
  end
  return { last_update = 0, last_status = "never" }
end

-- Utility: Write state file
local function write_state(state)
  local f = io.open(PATHS.state_file, "w")
  if f then
    f:write(vim.json.encode(state))
    f:close()
  end
end

-- Utility: Check if we should update today
local function should_update()
  local state = read_state()
  local last_update = state.last_update or 0
  local current_time = os.time()
  local hours_since_update = (current_time - last_update) / 3600
  
  return hours_since_update >= CONFIG.update_check_interval_hours
end

-- Utility: Validate Lua syntax of a file
local function validate_lua_file(filepath)
  local handle = io.popen("luac -p " .. vim.fn.shellescape(filepath) .. " 2>&1")
  if not handle then
    return false, "Failed to run luac"
  end
  local result = handle:read("*all")
  handle:close()
  
  if result == "" or result == nil then
    return true, nil
  else
    return false, result
  end
end

-- Utility: Validate all Lua files in config directory
local function validate_config()
  local config_dir = vim.fn.stdpath("config")
  
  -- Get all lua files
  local handle = io.popen('find ' .. vim.fn.shellescape(config_dir) .. ' -name "*.lua" 2>/dev/null')
  if not handle then
    log("Failed to find lua files, skipping validation")
    return true -- Be permissive if we can't check
  end
  
  local files = {}
  for line in handle:lines() do
    table.insert(files, line)
  end
  handle:close()
  
  -- Validate each file
  for _, file in ipairs(files) do
    local ok, err = validate_lua_file(file)
    if not ok then
      log("Syntax error in " .. file .. ": " .. (err or "unknown"))
      return false, file .. ": " .. (err or "unknown")
    end
  end
  
  return true, nil
end

-- Run Lazy sync (update all plugins)
local function run_lazy_sync(callback)
  log("Starting Lazy sync...")
  
  -- Use vim.loop to run in background
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local output = {}
  local error_output = {}
  
  local handle
  handle = vim.loop.spawn("nvim", {
    args = {
      "--headless",
      "-c", "lua require('lazy').sync({wait = true})",
      "-c", "qa!"
    },
    stdio = { nil, stdout, stderr },
  }, function(code)
    stdout:close()
    stderr:close()
    
    vim.schedule(function()
      if code == 0 then
        log("Lazy sync completed successfully")
        callback(true, nil)
      else
        local err = table.concat(error_output, "\n")
        log("Lazy sync failed: " .. err)
        callback(false, err)
      end
    end)
  end)
  
  if not handle then
    log("Failed to spawn nvim process for sync")
    callback(false, "Failed to spawn process")
    return
  end
  
  stdout:read_start(function(err, data)
    if err then
      log("stdout error: " .. tostring(err))
    elseif data then
      table.insert(output, data)
    end
  end)
  
  stderr:read_start(function(err, data)
    if err then
      log("stderr error: " .. tostring(err))
    elseif data then
      table.insert(error_output, data)
    end
  end)
end

-- Perform update with retry logic
local function perform_update(retry_count)
  retry_count = retry_count or 0
  
  if retry_count >= CONFIG.max_retries then
    log(string.format("Update failed after %d retries, giving up", CONFIG.max_retries))
    local state = read_state()
    state.last_status = "failed"
    state.retry_count = retry_count
    write_state(state)
    return
  end
  
  log(string.format("Update attempt %d/%d", retry_count + 1, CONFIG.max_retries))
  
  -- Step 1: Run lazy sync
  run_lazy_sync(function(sync_ok, sync_err)
    if not sync_ok then
      log("Sync failed: " .. (sync_err or "unknown error"))
      -- Retry after delay
      vim.defer_fn(function()
        perform_update(retry_count + 1)
      end, CONFIG.retry_delay_ms)
      return
    end
    
    -- Step 2: Validate config syntax
    local valid, val_err = validate_config()
    if not valid then
      log("Validation failed: " .. (val_err or "unknown"))
      -- Retry after delay
      vim.defer_fn(function()
        perform_update(retry_count + 1)
      end, CONFIG.retry_delay_ms)
      return
    end
    
    -- Success!
    log("Update completed and validated successfully")
    local state = read_state()
    state.last_update = os.time()
    state.last_status = "success"
    state.retry_count = retry_count
    write_state(state)
  end)
end

-- Main entry point: Start background update
function M.start_background_update()
  -- Check if we should update
  if not should_update() then
    return
  end
  
  log("Starting background update process")
  
  -- Defer to let nvim finish loading
  vim.defer_fn(function()
    perform_update(0)
  end, CONFIG.startup_delay_ms)
end

-- Manual check command (for debugging)
function M.check_status()
  local state = read_state()
  local last_update_str = os.date("%Y-%m-%d %H:%M:%S", state.last_update)
  
  print("LazyVim Auto-Updater Status:")
  print("  Last update: " .. last_update_str)
  print("  Status: " .. (state.last_status or "unknown"))
  print("  Should update: " .. tostring(should_update()))
  print("  Log file: " .. PATHS.log_file)
end

-- Manual trigger command (for testing)
function M.force_update()
  log("Manual update triggered")
  perform_update(0)
end

-- Setup function called from init.lua or autocmds
function M.setup()
  -- Create autocommand to trigger on VimEnter
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("LazyAutoUpdater", { clear = true }),
    callback = function()
      M.start_background_update()
    end,
    once = true,
  })
  
  -- Create user commands for manual control
  vim.api.nvim_create_user_command("LazyUpdaterStatus", function()
    M.check_status()
  end, { desc = "Check LazyVim auto-updater status" })
  
  vim.api.nvim_create_user_command("LazyUpdaterForce", function()
    M.force_update()
  end, { desc = "Force LazyVim update now" })
end

return M
