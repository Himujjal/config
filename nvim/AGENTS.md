# AGENTS.md

Guidance for AI agents (and humans) working in this repo.

This file exists so an agent can (1) find the right file to change, (2) write code
that matches house style, and (3) validate without breaking the config.

---

## 1. Scope

Config lives in `~/.config/nvim/`. Files an agent may touch:

- `init.lua`, `lua/**`, `lazyvim.json`, `queries/**`, `stylua.toml`, `.neoconf.json`
- `README.md`, `AGENTS.md`

**Generated / off-limits:** `lazy-lock.json` (managed by lazy.nvim), `.env` (secrets),
`spell/` (personal spellfiles), `.git/`.

---

## 2. Codemap (2 levels deep)

```
~/.config/nvim/
├── init.lua                     # ENTRYPOINT — wire modules only, no logic
├── lazy-lock.json               # GENERATED — never edit by hand
├── lazyvim.json                 # LazyVim extras + version pin
├── stylua.toml                  # formatter config (2-space indent, 120 col)
├── .neoconf.json                # LuaLS / neoconf settings
├── .env                         # SECRETS — gitignored, never touch
│
├── lua/
│   ├── config/                  # ── CORE EDITOR CONFIG (LazyVim canonical) ──
│   │   ├── lazy.lua             #   lazy.nvim bootstrap + ALL plugin imports + defaults
│   │   ├── options.lua          #   global vim.o / vim.g (leader, netrw, autoformat)
│   │   ├── keymaps.lua          #   ONLY generic + custom (plugin-less) keymaps
│   │   └── autocmds.lua         #   ONLY global autocmds + global filetype.add
│   │
│   ├── modules/                 # ── YOUR REUSABLE LOGIC (no specs, no keymaps) ──
│   │   ├── dotenv.lua           #   load .env into vim.env
│   │   ├── buffers.lua          #   buffer nav/close helpers
│   │   ├── neovide.lua          #   Neovide GUI settings + font resize
│   │   ├── updater.lua          #   silent auto-updater (state + retry + validate)
│   │   ├── kimish.lua           #   kimish terminal session manager
│   │   ├── yazi.lua             #   yazi floating-terminal integration
│   │   └── ekon/
│   │       ├── init.lua         #   ekon helpers (parser check, format, validate)
│   │       └── treesitter.lua   #   ekon parser register + install + tree helpers
│   │
│   └── plugins/                 # ── PLUGIN SPECS (declarative, thin) ──
│       ├── disabled.lua         #   LazyVim disablements/overrides (nvim-tree, snacks)
│       ├── editor/              #   editing / completion / explorer
│       │   ├── cmp.lua          #     nvim-cmp context-disable rules
│       │   ├── explorer.lua     #     neo-tree (opts + keys + highlights)
│       │   ├── formatting.lua   #     conform.nvim formatters
│       │   └── window-picker.lua#     window-picker
│       ├── lang/                #   LSP / treesitter / filetypes
│       │   ├── lsp.lua          #     lspconfig servers + none-ls + treesitter + Lsp* cmds
│       │   └── ekon.lua         #     ekon filetype + .ek LSP-disable + install cmd
│       ├── ai/                  #   AI coding
│       │   ├── supermaven.lua   #     supermaven + <C-l> accept
│       │   ├── sidekick.lua     #     sidekick + all <leader>a keys
│       │   ├── gp.lua           #     gp.nvim config + all <C-g> keys
│       │   └── review.lua       #     review.nvim + codediff + <leader>r keys
│       ├── ui/                  #   themes / appearance
│       │   └── colorscheme.lua  #     rose-pine, tokyonight, transparent + ACTIVE theme
│       └── tools/               #   misc utilities
│           ├── telescope.lua    #     telescope + <leader>fw live-grep
│           ├── obsidian.lua     #     obsidian vault
│           ├── bruno.lua        #     bruno API collections
│           ├── peek.lua         #     markdown preview + <leader>mp
│           └── search-and-replace.lua  # buffer search & replace UI
│
├── queries/
│   └── ekon/                    # ekon tree-sitter queries (runtime path)
│       ├── highlights.scm
│       ├── indents.scm
│       └── injections.scm
│
└── spell/                       # personal spellfiles — don't touch
```

**Import note:** `lua/config/lazy.lua` imports plugin categories explicitly:
`plugins`, `plugins.editor`, `plugins.lang`, `plugins.ai`, `plugins.ui`, `plugins.tools`.
A new category directory needs a matching `{ import = "plugins.<category>" }` entry.

---

## 3. Mental model: two kinds of Lua, never mixed

| Kind | Location | Returns | May do |
|---|---|---|---|
| **Spec** | `lua/plugins/**` | table of plugin specs | `opts`, `keys`, `dependencies`, tiny `config`/`init` |
| **Module** | `lua/modules/**` | module table `M` | functions, state; `M.setup()` for wiring |

Rules:

- **Specs are declarative.** Push logic into `modules/`; keep `config`/`init` bodies short.
- **Modules have no side effects at load time.** Register commands/autocmds inside
  `M.setup()`, which `init.lua` (or a spec) calls. Modules never set global keymaps.
- **Keymaps co-locate with their feature:** plugin keymaps go in the spec's `keys` field;
  custom plugin-less keymaps (kimish, yazi) go in `lua/config/keymaps.lua`.

---

## 4. Where do I make a change?

| Change | File |
|---|---|
| Install/configure a plugin | `lua/plugins/<category>/<name>.lua` |
| Add a global vim option | `lua/config/options.lua` |
| Add a generic/global keymap | `lua/config/keymaps.lua` |
| Add a global autocmd/filetype | `lua/config/autocmds.lua` |
| Add a plugin-scoped keymap | that spec's `keys` field |
| Change the active theme | `lua/plugins/ui/colorscheme.lua` |
| Add an LSP server | `lua/plugins/lang/lsp.lua` (`servers` table) |
| Add a formatter | `lua/plugins/editor/formatting.lua` |
| Add a treesitter parser | `lua/plugins/lang/lsp.lua` (`ensure_installed`) |
| Disable/override a LazyVim default | `lua/plugins/disabled.lua` |
| Write custom logic | `lua/modules/<name>.lua` (+ `M.setup()`) |
| Wire a custom module at startup | `init.lua` |

---

## 5. Lua style skills

- **Format with stylua** before finishing (see §8). `stylua.toml`: 2-space indent, 120-col.
- **`local` everything.** No new globals. (The `LazyVim` global is provided by LazyVim and is fine.)
- **Modules return a table.** Public API is `M.foo`; internal helpers are `local function`.

  ```lua
  -- good
  local M = {}
  local state = nil
  local function helper() end
  function M.do_thing() helper() end
  return M
  ```

- **No load-time side effects in modules.** Wrap command/autocmd registration in `M.setup()`.
- **File header:** one line stating purpose. `-- <Feature>: <one-line purpose>.`
- **Naming:** `snake_case` for files/vars/functions; `UPPER_SNAKE` for constants;
  `PascalCase` only for types/classes.
- **LuaLS annotations on public functions** so LSP/agents understand signatures:

  ```lua
  ---@param step integer
  ---@return nil
  function M.buf_nav(step) end
  ```

- **Use stdlib helpers:** `vim.tbl_map`/`vim.tbl_filter`/`vim.list_*`/`vim.iter`
  over hand-rolled loops. `vim.fn.fnamemodify`/`vim.fs.*` for paths.
- **Early returns** over deep nesting.
- **One concern per function/file.** If a spec grows >~50 lines of *logic*, extract to `modules/`.

---

## 6. Neovim / LazyVim style skills

- **Options:** use `vim.opt`/`vim.o`/`vim.g` for globals; `vim.opt_local`/`vim.bo` for buffer-local;
  `vim.api.nvim_set_option_value` only for window-scoped changes.
- **Keymaps:** `vim.keymap.set(mode, lhs, rhs, { desc = "..." })` — always a `desc`.
  In `config/keymaps.lua`, follow the existing `mappings` table + `LazyVim.safe_keymap_set` loop.
- **Autocmds:** `vim.api.nvim_create_autocmd(event, { pattern, callback, desc, group })` — always `desc`.
- **Commands:** `vim.api.nvim_create_user_command("Name", fn, { desc = "..." })`.
- **Plugin specs are declarative.** Prefer the `opts` pattern (auto-merged with LazyVim
  defaults + auto-calls `.setup(opts)`); only write `config`/`init` when there is no `opts` hook.

  ```lua
  -- good (declarative)
  { "owner/repo", event = "VeryLazy", keys = { { "<leader>x", "<cmd>X<cr>", desc = "X" } }, opts = {} }

  -- avoid unless necessary
  { "owner/repo", config = function() require("repo").setup({ ... }) end }
  ```

- **Lazy-load** with `event`/`cmd`/`ft`/`keys`. Do not set `lazy = false` on a new plugin
  unless it must load at startup.
- **Don't re-declare LazyVim-provided plugins** (`plenary`, `nui`, `telescope`, `nvim-cmp` …).
  Override their config via a minimal spec using `opts`, or disable via `enabled = false`
  in `disabled.lua`.
- **Colorscheme:** set through `{ "LazyVim/LazyVim", opts = { colorscheme = "..." } }`
  in `ui/colorscheme.lua` — never `vim.cmd.colorscheme` in options.
- **Prefer modern API** (`vim.api.nvim_*`) over legacy (`vim.fn`, string `vim.cmd`) when a
  native equivalent exists. Exceptions: things with no API (e.g. `vim.fn.fnamemodify`).

---

## 7. Guardrails — what NOT to do

- Don't reformat or refactor files unrelated to the requested change.
- Don't change lazy-loading (`event`/`cmd`/`ft`/`lazy`) or startup behavior unless asked.
- Don't hand-edit `lazy-lock.json`.
- Don't read, edit, or echo `.env` contents.
- Don't add/remove/upgrade plugins without an explicit request.
- Don't introduce globals (`_G`).
- Don't put logic in specs, or keymaps/specs in modules.
- Don't remove existing `desc` fields or keymap semantics.
- **Preserve behavior.** If you intentionally change behavior (bug fix, tweak),
  say so explicitly in your report.
- Keep any `config`/`init` function short; extract to `modules/` if it grows.

---

## 8. Validation (run before reporting done)

```bash
# 1. format
~/.local/share/nvim/mason/bin/stylua lua/ init.lua

# 2. boot — expect BOOT_OK and exit 0
nvim --headless -c 'lua require("config.lazy")' -c 'lua print("BOOT_OK")' -c qa 2>&1

# 3. specs — expect no INVALID lines
nvim --headless -c 'lua require("config.lazy")' \
  -c 'lua for _,p in ipairs(require("lazy").plugins()) do if p._ and p._.invalid then print("INVALID: "..p.name) end end' \
  -c qa 2>&1

# 4. sync (only when plugins changed)
nvim --headless -c 'Lazy! sync' -c 'qa!'
```

Smoke checklist: `nvim` starts clean · colorscheme applies · `<leader>e` toggles neo-tree ·
LSP attaches on `.lua`/`.ts` · `<C-g>c` opens GP · `<leader>k` toggles kimish · `<leader>yz`
toggles yazi · `.ekon` file gets `ekon` filetype, no LSP · `}`/`{` and `<C-h/j/k/l>` navigate.

---

## 9. Debugging (no DOM — use headless/embed)

- Startup: `nvim --startuptime /tmp/startup.log +qa && sort -k2 -nr /tmp/startup.log | head -n 20`
- Verbose: `nvim -V9/tmp/nvim-verbose.log +qa; tail -n 100 /tmp/nvim-verbose.log`
- Remote: `nvim --listen /tmp/nvim.sock --headless &` → `nvim --server /tmp/nvim.sock --remote-send ...`
- TUI snapshot: `tmux new -d -s t "nvim -u init.lua"; tmux capture-pane -p -e -t t`
- Inspect: `:Inspect`, `:messages`, `:LspInfo`, `:LspLog`, `vim.api.nvim_buf_get_extmarks()`
- Logs: `~/.local/state/nvim/log`, `~/.local/state/nvim/lsp.log`

---

## 10. Report format

After any change, report: **what changed** (files + why) · **validation commands run + output**
· **any intentional behavior change** · **screenshot/`messages` on failure**.
