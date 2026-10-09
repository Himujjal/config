# AGENTS.md

Guidance for AI agents (and humans) working in this repo.

## Scope

- Config: `init.lua`, `lua/`, `lazyvim.json`, `lazy-lock.json`, `queries/`, `stylua.toml`.
- Keep changes minimal and LazyVim-compatible. Don't refactor unrelated files.
- Format Lua with `~/.local/share/nvim/mason/bin/stylua lua/ init.lua` (see `stylua.toml`).

## Golden rules

1. **Two kinds of Lua, never mix them:**
   - `lua/plugins/**` → plugin **specs** (return a table; declarative `opts`/`keys`/`dependencies`).
   - `lua/modules/**` → **logic** (module table `M`; no specs, no global keymaps).
2. **Co-locate, don't centralize:** keymaps/autocmds for a *plugin* live in that spec's
   `keys`/`init`, not in `lua/config/keymaps.lua` or `autocmds.lua`.
   - Exception: custom, plugin-less modules (e.g. kimish, yazi) wire their keymaps in
     `lua/config/keymaps.lua` and register commands/autocmds in their `M.setup()`.
3. **Every keymap has a `desc`.**
4. **Never edit `lazy-lock.json` by hand.** Let `:Lazy` manage it.
5. **Never touch `.env`.** Secrets stay gitignored.
6. **Only import non-empty plugin categories** in `lua/config/lazy.lua`. A new category dir
   needs `{ import = "plugins.<category>" }`.

## Where does X go?

| If you're… | Put it in… |
|---|---|
| Installing/configuring a plugin | `lua/plugins/<category>/<name>.lua` |
| Writing custom logic/helpers | `lua/modules/<name>.lua` |
| Adding a global vim option | `lua/config/options.lua` |
| Adding a truly global keymap | `lua/config/keymaps.lua` |
| Adding a global autocmd/filetype | `lua/config/autocmds.lua` |
| Adding a plugin-scoped keymap | the spec's `keys` field |
| Changing the theme | `lua/plugins/ui/colorscheme.lua` |
| Disabling/overriding a LazyVim default | `lua/plugins/disabled.lua` |

## Categories

`editor/` (editing/completion/explorer) · `lang/` (LSP/treesitter/filetypes) ·
`ai/` (AI coding) · `ui/` (themes/appearance) · `tools/` (misc utilities)

## Required validation before finishing any change

```bash
# 1. format
~/.local/share/nvim/mason/bin/stylua lua/ init.lua

# 2. boot check — expect BOOT_OK and exit 0
nvim --headless -c 'lua require("config.lazy")' -c 'lua print("BOOT_OK")' -c qa 2>&1

# 3. plugin spec check — expect no INVALID lines
nvim --headless -c 'lua require("config.lazy")' \
  -c 'lua for _,p in ipairs(require("lazy").plugins()) do if p._ and p._.invalid then print("INVALID: "..p.name) end end' \
  -c qa 2>&1

# 4. sync check
nvim --headless -c 'Lazy! sync' -c 'qa!'
```

## Smoke-test checklist (manual)

- [ ] `nvim` starts clean, no error messages
- [ ] colorscheme applies
- [ ] `<leader>e` toggles neo-tree; `<leader>E` reveals; `.` sets cwd
- [ ] LSP attaches on a `.lua`/`.ts` file; `:LspInfo` works
- [ ] `<C-g>c` opens GP chat; `<leader>aa` toggles sidekick
- [ ] `<leader>k` toggles kimish; `<leader>yz` toggles yazi
- [ ] `.ekon` file → filetype `ekon`, no LSP attach
- [ ] buffer nav (`}`/`{`), window nav (`<C-h/j/k/l>`) work

## Debugging

Neovim has no DOM — use headless/embed UI instead of Playwright.

- Startup issue:
  `nvim --startuptime /tmp/startup.log +qa && sort -k2 -nr /tmp/startup.log | head -n 20`
- Behavior issue:
  `nvim -V9/tmp/nvim-verbose.log +qa; tail -n 100 /tmp/nvim-verbose.log`
- Headless server + remote send:
  `nvim --listen /tmp/nvim.sock --headless &` then `nvim --server /tmp/nvim.sock --remote-send ...`
- TUI snapshot:
  `tmux new -d -s nvim-test "nvim -u init.lua"; tmux capture-pane -p -e -t nvim-test`
- Lua asserts / inspection:
  `vim.api.nvim_win_get_config(0)`, `vim.api.nvim_buf_get_extmarks()`, `:Inspect`, `:messages`, `:LspInfo`, `:LspLog`
- Logs: `~/.local/state/nvim/log`, `~/.local/state/nvim/lsp.log`

Return: what changed, the headless command run, and `messages` / screenshot output on failure.
