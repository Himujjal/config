# Neovim Config

A composable [LazyVim](https://github.com/LazyVim/LazyVim)-based setup.

## Layout

| Path | Purpose | Rule |
|---|---|---|
| `init.lua` | Thin entrypoint: dotenv → lazy bootstrap → custom module setup | No logic here |
| `lua/config/` | Core editor config (options, keymaps, autocmds, lazy bootstrap) | LazyVim's canonical files |
| `lua/plugins/` | Plugin **specs** — declarative, one concern per file | Return a table of specs; no logic |
| `lua/modules/` | Your **code** — reusable logic/helpers | No specs; no global keymaps |
| `queries/` | Tree-sitter queries (runtime path) | — |
| `.env` | API keys (gitignored) | Never commit |

### Plugin categories (`lua/plugins/`)

| Category | Contents |
|---|---|
| `editor/` | cmp, explorer (neo-tree), formatting (conform), window-picker |
| `lang/` | lsp (lspconfig + none-ls + treesitter), ekon |
| `ai/` | supermaven, sidekick, gp, review |
| `ui/` | colorscheme (themes + active colorscheme) |
| `tools/` | telescope, obsidian, bruno, peek, search-and-replace |

Top-level files like `disabled.lua` hold LazyVim disablements/overrides.

## Adding a plugin

1. Create `lua/plugins/<category>/<name>.lua`:

   ```lua
   return {
     {
       "owner/repo",
       event = "VeryLazy",
       keys = { { "<leader>x", "<cmd>...<cr>", desc = "..." } },
       opts = {},
     },
   }
   ```

2. If `<category>` is new, add `{ import = "plugins.<category>" }` to `lua/config/lazy.lua`.
3. Run `:Lazy` → sync.

## Changing the theme

Edit `lua/plugins/ui/colorscheme.lua` — one line sets the active colorscheme:

```lua
{ "LazyVim/LazyVim", opts = { colorscheme = "rose-pine" } }
```

## Custom modules (no plugin needed)

`kimish` (terminal session) and `yazi` (file manager) are custom integrations:
logic lives in `lua/modules/`, commands/autocmds are registered in `setup()`
(called from `init.lua`), and their keymaps live in `lua/config/keymaps.lua`.

To add your own, mirror that pattern: write `lua/modules/<name>.lua`, expose a
`setup()`, call it from `init.lua`, and put any keymaps in `lua/config/keymaps.lua`.

## Keymap prefixes

| Prefix | Domain |
|---|---|
| `<leader>a` | AI (sidekick) |
| `<leader>b` | Buffers |
| `<leader>e/E/o` | Explorer (neo-tree) |
| `<leader>f` | Find (telescope) |
| `<leader>k` | Kimish terminal |
| `<leader>l` | Code / LSP |
| `<leader>m` | Markdown (peek) |
| `<leader>r` | Review |
| `<leader>y` | Yazi |
| `<C-g>` | GP.nvim |

## Secrets

API keys live in `.env` (loaded by `modules/dotenv.lua` before anything else).
Keep it out of git.

## Updating & validating

```bash
~/.local/share/nvim/mason/bin/stylua lua/ init.lua   # format
nvim --headless -c 'lua require("config.lazy")' -c 'lua print("BOOT_OK")' -c qa
nvim --headless -c 'Lazy! sync' -c 'qa!'
```

See `AGENTS.md` for the full checklist.
