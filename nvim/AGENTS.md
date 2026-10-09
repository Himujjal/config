# AGENTS.md - nvim config

This file guides AI agents making changes to this Neovim config.

## Scope
- Config: `init.lua`, `lua/`, `lazyvim.json`, `lazy-lock.json`
- Keep changes minimal, LazyVim-compatible. Don't refactor unrelated files.
- Run `stylua` for Lua formatting (see `stylua.toml`).

## Change workflow
1. Edit `lua/` files.
2. Sanity check headless:
  `nvim --headless --clean +qa`
  `nvim --headless "+checkhealth" +qa 2>&1 | head -n 50`
3. If startup issue: `nvim --startuptime /tmp/startup.log +qa && sort -k2 -nr /tmp/startup.log | head -n 20`
4. If behavior issue: `nvim -V9/tmp/nvim-verbose.log +qa; tail -n 100 /tmp/nvim-verbose.log`

## UI debug (Playwright-like, CLI-only)
Neovim has no DOM. Use embed / headless UI instead of Playwright:
- `nvim --listen /tmp/nvim.sock --headless &` then `nvim --server /tmp/nvim.sock --remote-send`
- TUI snapshot: `tmux new -d -s nvim-test "nvim -u init.lua"; tmux capture-pane -p -e -t nvim-test`
- Lua asserts: `vim.api.nvim_win_get_config(0)`, `vim.api.nvim_buf_get_extmarks()`, `:Inspect`, `:messages`, `:LspInfo`, `:LspLog`
- Logs: `~/.local/state/nvim/log`, `~/.local/state/nvim/lsp.log`
- Prefer `mini.test` `child.get_screenshot()` / `child.expect_screenshot()` for regression.

Return: what changed, headless test command run, and `messages` / screenshot output on failure.
