# Neovim Enhancement Plan

## Goals
1. Replace default file explorer with the best tool (oil.nvim)
2. Implement silent automatic LazyVim updates on startup (background, one-time, no notifications on failure)
3. Validate updates with syntax checking before applying (max 3 retries)
4. Ensure robust architecture with proper error handling

---

## Phase 1: File Explorer Replacement

### Research Decision: oil.nvim
- **Why oil.nvim over alternatives:**
  - `nvim-tree`: Heavy, sidebar-based (similar to what we're replacing)
  - `mini.files`: Minimal but lacks features
  - `neo-tree`: Already used, buffer-based
  - `yazi.nvim`: Already configured, external dependency
  - **oil.nvim**: Buffer-as-file explorer paradigm, modern, lightweight, no external deps, integrates with telescope/fzf

### Implementation:
1. Disable neo-tree (LazyVim default)
2. Install and configure oil.nvim
3. Set up keybindings for `<leader>e` and `<leader>E`
4. Configure oil to be the default file explorer

---

## Phase 2: Silent Auto-Update System

### Architecture:
```
init.lua
├── config/lazy.lua (bootstrap)
├── config/updater.lua (new - background update logic)
└── plugins/*.lua
```

### Design Decisions:

#### Why Lua + Neovim's libuv (vim.loop) instead of external scripts?
1. **Portability**: No external dependencies (no bash/python scripts needed)
2. **Integration**: Direct access to Neovim's config path
3. **Control**: Can access lazy.nvim's API directly
4. **Cleanup**: Easier to manage temp files within nvim's ecosystem

#### Background Process Strategy:
- Use `vim.loop.spawn()` for non-blocking async operations
- Use `vim.defer_fn()` to delay start (after UI loads)
- State file: `vim.fn.stdpath("data") .. "/lazy-update-state.json"`

#### Update Flow:
```
VimEnter → defer 2s → Check if updated today? → No → Start Background Update
                                      ↓
                            Create temp git clone
                                      ↓
                            Run syntax validation
                                      ↓
                            If valid → Apply update → Mark complete
                            If invalid → Retry (max 3) → Silent fail
```

### File Structure:
```
lua/
├── config/
│   ├── lazy.lua          (existing - bootstrap)
│   ├── updater.lua       (new - silent auto-update logic)
│   └── autocmds.lua      (add VimEnter trigger)
├── plugins/
│   ├── explorer.lua      (new - oil.nvim config)
│   └── disabled.lua      (new - disable neo-tree)
```

---

## Phase 3: Implementation Steps

1. **Create oil.nvim configuration** (`lua/plugins/explorer.lua`)
2. **Disable neo-tree** (via LazyVim opts or `lua/plugins/disabled.lua`)
3. **Create updater module** (`lua/config/updater.lua`)
4. **Add VimEnter autocmd** to trigger updater
5. **Test configuration** (syntax check, oil.nvim functionality)
6. **Cleanup any temp files**
7. **Commit changes**

---

## Phase 4: Testing Checklist

- [x] oil.nvim opens with `<leader>e`
- [x] oil.nvim opens in cwd with `<leader>E`
- [x] Can navigate directories in oil buffer
- [x] Can create/delete/rename files
- [x] neo-tree no longer loads
- [x] Updater state file logic works
- [x] Update validation (syntax check) works
- [x] Retry mechanism (max 3) works
- [x] Silent failure (no notifications on error)

---

## Retry Logic Details

```lua
local MAX_RETRIES = 3
local RETRY_DELAY_MS = 5000

function attempt_update(retry_count)
  if retry_count >= MAX_RETRIES then
    -- Silent fail - log to file only
    return
  end
  
  -- Try update
  -- Validate with: luac -p init.lua && luac -p lua/**/*.lua
  -- If fail: schedule retry with vim.defer_fn
end
```
