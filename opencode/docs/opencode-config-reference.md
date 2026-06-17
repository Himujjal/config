# opencode Configuration Reference

> Generated from the customize-opencode skill and upstream schema.
> Authoritative schema: <https://opencode.ai/config.json>

---

## Where Files Live

| Scope | Path |
|---|---|
| Project config | `./opencode.json`, `./opencode.jsonc`, `.opencode/opencode.json` (walks up from cwd to worktree root) |
| Global config | `~/.config/opencode/opencode.json` |
| Project agents | `.opencode/agent/<name>.md` or `.opencode/agents/<name>.md` |
| Global agents | `~/.config/opencode/agent(s)/<name>.md` |
| Project skills | `.opencode/skill(s)/<name>/SKILL.md` |
| Global skills | `~/.config/opencode/skill(s)/<name>/SKILL.md` |
| Auto-loaded external skills | `~/.claude/skills/<name>/SKILL.md`, `~/.agents/skills/<name>/SKILL.md` |

Configs from each scope are deep-merged. Project overrides global. Unknown top-level keys are rejected with `ConfigInvalidError`. **Config is loaded once at startup and is not hot-reloaded** — restart opencode after changes.

---

## Complete `opencode.json` Shape

Every field is optional.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",

  // --- Identity ---
  "username": "string",

  // --- Models (always "provider/model-id") ---
  "model": "anthropic/claude-sonnet-4-6",
  "small_model": "anthropic/claude-haiku-4-5",

  // --- Agents ---
  "default_agent": "agent-name",
  "agent": {
    "my-agent": {
      "model": "anthropic/claude-sonnet-4-6",
      "mode": "subagent",         // "primary" | "subagent" | "all"
      "description": "...",
      "permission": { "edit": "deny" }
    }
  },

  // --- Shell ---
  "shell": "/bin/zsh",

  // --- Logging ---
  "logLevel": "DEBUG" | "INFO" | "WARN" | "ERROR",

  // --- Share / Telemetry ---
  "share": "manual" | "auto" | "disabled",
  "autoupdate": true | false | "notify",
  "snapshot": true,

  // --- Instructions (loaded into system prompt) ---
  "instructions": ["AGENTS.md", "docs/style.md"],

  // --- Skills ---
  "skills": {
    "paths": [".opencode/skills", "/abs/path/to/skills"],
    "urls": ["https://example.com/.well-known/skills/"]
  },

  // --- Commands ---
  "command": {
    "deploy": {
      "description": "Deploy the application",
      "prompt": "Run the deployment script..."
    }
  },

  // --- Providers ---
  "provider": {
    "anthropic": { "options": { "apiKey": "..." } }
  },
  "disabled_providers": ["openai"],
  "enabled_providers": ["anthropic"],

  // --- MCP Servers ---
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp"],
      "enabled": true,
      "env": { "BROWSER": "chromium" }
    },
    "remote-thing": {
      "type": "remote",
      "url": "https://...",
      "headers": { "Authorization": "Bearer ${TOKEN}" }
    }
  },

  // --- Plugins ---
  "plugin": [
    "opencode-gemini-auth",
    "opencode-foo@1.2.3",
    "./local-plugin.ts",
    ["opencode-bar", { "option": "value" }]
  ],

  // --- Permissions ---
  "permission": {
    "edit": "deny",
    "bash": { "git *": "allow", "rm *": "deny", "*": "ask" },
    "external_directory": { "~/secrets/**": "deny", "*": "allow" }
  },

  // --- Features ---
  "formatter": false,
  "lsp": false,

  // --- Experimental ---
  "experimental": {
    "primary_tools": ["edit"],
    "mcp_timeout": 30000
  },

  // --- Tool Output ---
  "tool_output": {
    "max_lines": 200,
    "max_bytes": 8192
  },

  // --- Compaction ---
  "compaction": {
    "auto": true,
    "tail_turns": 15
  },

  // --- Plan Mode ---
  "mode": {
    "plan": {
      "tools": {
        "write": false,
        "edit": false,
        "bash": false,
        "patch": false
      }
    }
  },

  // --- Tool toggles ---
  "tools": {
    "webfetch": true
  }
}
```

---

## Config Field Details

### `model` / `small_model`

Always prefixed with provider: `"anthropic/claude-sonnet-4-6"`, `"groq/qwen/qwen3-32b"`, `"accounts/himujjal/deployedModels/..."`.

### `agent`

Objects keyed by agent name (not an array).

| Field | Type | Description |
|---|---|---|
| `name` | string | Agent name (from key or frontmatter) |
| `mode` | `"primary"` | `"subagent"` | `"all"` | How the agent operates |
| `model` | string | Per-agent model override |
| `description` | string | Shown in agent picker |
| `permission` | object | Per-agent permission overrides |
| `prompt` | string | System prompt (inline or file body) |
| `hidden` | boolean | Hide from picker |
| `color` | string | Theme color |
| `disable` | boolean | Disable a built-in agent |
| `temperature` | number | Model temperature |
| `top_p` | number | Model top_p |

To disable a built-in agent: `agent: { build: { disable: true } }`.

Built-in agents: `build`, `plan`, `general`, `explore`, (optionally `scout`). Hidden: `compaction`, `title`, `summary`.

### `agent` File Form

File at `.opencode/agent/<name>.md` or `.opencode/agents/<name>.md`:

```markdown
---
description: Reviews PRs for style violations.
mode: subagent
model: anthropic/claude-sonnet-4-6
permission:
  edit: deny
  bash: ask
---

You are a strict PR reviewer. Focus on...
```

The file body becomes the agent's `prompt`. Do not also put `prompt:` in frontmatter.

### `skills`

Object with `paths` (array of directories scanned for `**/SKILL.md`) and/or `urls` (array of URLs serving skill manifests).

Each skill is a `SKILL.md` file in its own folder:

```markdown
---
name: my-skill
description: "Use when [triggers/keywords]: One sentence description."
---

# My Skill

Instructions...
```

Frontmatter: `name` (required, lowercase hyphen-separated, ≤64 chars), `description` (effectively required), optional `license`, `compatibility`, `metadata`.

### `command`

Object keyed by command name. Each command has `description` and `prompt`.

### `provider`

Object keyed by provider name (e.g. `anthropic`, `openai`, `groq`), each with `options` (any provider-specific settings like `apiKey`).

### `mcp`

Object keyed by server name. Each server:

| Field | Type | Required |
|---|---|---|
| `type` | `"local"` | `"remote"` | yes |
| `command` | string[] | for `local` |
| `url` | string | for `remote` |
| `enabled` | boolean | optional (default true) |
| `env` | object | optional, env vars for `local` |
| `headers` | object | optional, HTTP headers for `remote` |

Use `enabled: false` to disable an inherited server.

### `plugin`

Array of plugin specs. Each entry:

- `"opencode-foo"` — npm package (latest)
- `"opencode-foo@1.2.3"` — npm package (pinned)
- `"./local-plugin.ts"` — file path relative to declaring config
- `"file:///abs/path/plugin.js"` — absolute file URL
- `["opencode-bar", { "option": "value" }]` — tuple form with options

Auto-discovered (no config needed): any `*.ts` or `*.js` in `.opencode/plugin/` or `.opencode/plugins/`.

Plugin module exports:

```ts
import type { Plugin } from "@opencode-ai/plugin"

export default (async ({ client, project, directory, $ }) => {
  return {
    config: (cfg) => { /* mutate cfg */ },
    "tool.execute.before": async (input, output) => { /* mutate output.args */ },
    // ... other hooks
  }
}) satisfies Plugin
```

Available hooks:
- `event(input)` — every bus event
- `config(cfg)` — once on init with merged config
- `chat.message`, `chat.params`, `chat.headers`
- `tool.execute.before`, `tool.execute.after`
- `tool.definition`
- `command.execute.before`
- `shell.env`
- `permission.ask`
- `experimental.chat.messages.transform`, `experimental.chat.system.transform`
- `experimental.session.compacting`, `experimental.compaction.autocontinue`
- `experimental.text.complete`

Object-shaped plugin returns (not callbacks): `tool: { my_tool: { ... } }`, `auth: { ... }`, `provider: { ... }`.

### `permission`

| Form | Meaning |
|---|---|
| `"allow"` | Allow everything (top-level shorthand) |
| `{ "edit": "deny" }` | Per-action flat value |
| `{ "bash": { "git *": "allow", "*": "ask" } }` | Per-tool pattern object |

Actions: `"allow"`, `"ask"`, `"deny"`. **Insertion order matters** — last matching rule wins.

Known permission keys: `read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `external_directory`, `todowrite`, `question`, `webfetch`, `websearch`, `repo_clone`, `repo_overview`, `lsp`, `doom_loop`, `skill`.

Some keys only accept a flat action (not per-pattern): `todowrite`, `question`, `webfetch`, `websearch`, `doom_loop`.

`external_directory` patterns are filesystem paths (`~/`, absolute, or globs).

Per-agent `permission` overrides top-level `permission`.

### `mode.plan`

```json
{
  "mode": {
    "plan": {
      "tools": {
        "write": false,
        "edit": false,
        "bash": false,
        "patch": false
      }
    }
  }
}
```

Disables write/edit/bash/patch tools in plan mode.

### `tools`

Boolean toggles for individual tools (e.g. `"webfetch": true`).

### Other Fields

- `"formatter": false` — disable the built-in formatter
- `"lsp": false` — disable LSP
- `"tool_output": { "max_lines": 200, "max_bytes": 8192 }`
- `"compaction": { "auto": true, "tail_turns": 15 }`

---

## TUI Config (`tui.json`)

Lives at `~/.config/opencode/tui.json`:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "rosepine"
}
```

Theme values: any built-in theme name (e.g. `"rosepine"`).

---

## Plugin Hooks Reference

| Hook | Signature |
|---|---|
| `config` | `(cfg: Config) => void` |
| `event` | `(input: EventInput) => void` |
| `chat.message` | `(input, output: { messages }) => void` |
| `chat.params` | `(input, output: { params }) => void` |
| `chat.headers` | `(input, output: { headers }) => void` |
| `tool.execute.before` | `(input, output: { args }) => void` |
| `tool.execute.after` | `(input, output) => void` |
| `tool.definition` | `(input, output: { definition }) => void` |
| `command.execute.before` | `(input, output) => void` |
| `shell.env` | `(input, output: { env }) => void` |
| `permission.ask` | `(input, output) => void` |
| `experimental.chat.messages.transform` | `(input, output) => void` |
| `experimental.chat.system.transform` | `(input, output) => void` |
| `experimental.session.compacting` | `(input, output) => void` |
| `experimental.compaction.autocontinue` | `(input, output) => void` |
| `experimental.text.complete` | `(input, output) => void` |

All hooks mutate `output` in place and return `void`.

---

## Escape Hatches (When Config Breaks)

| Env var | Effect |
|---|---|
| `OPENCODE_DISABLE_PROJECT_CONFIG=1` | Skip project's local config, start from globals only |
| `OPENCODE_CONFIG=/path/to/file.json` | Load additional explicit config |
| `OPENCODE_CONFIG_CONTENT='{"$schema":"..."}'` | Inject inline JSON as final local merge |
| `OPENCODE_DISABLE_DEFAULT_PLUGINS=1` | Skip default plugins |
| `OPENCODE_PURE=1` | Skip external plugins entirely |
| `OPENCODE_DISABLE_EXTERNAL_SKILLS=1` | Skip external skill scans |
| `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1` | Skip `~/.claude/` skills |

---

## Key Rules

1. **Restart after config changes** — config is loaded once at startup.
2. **`model` always has a provider prefix** (`"provider/model-id"`).
3. **`mcp[name].command` is an array** of strings, never a single string.
4. **`permission` evaluates last matching rule** — order matters in pattern objects.
5. **`plugin` is an array** of strings or `[name, options]` tuples, not an object.
6. **`skills` is an object** with `paths` and/or `urls`, not an array.
7. **`agent` is an object** keyed by name, not an array.
8. **Unknown top-level keys are rejected** — `ConfigInvalidError`.
9. **Declare `"$schema": "https://opencode.ai/config.json"`** for editor autocomplete.
10. **Always validate against the schema** — fetch `https://opencode.ai/config.json` if unsure.
