---
name: issue
description: Grill down a problem or feature idea then file a Forgejo or GitHub issue for it.
argument-hint: "[problem or feature one-liner]"
---

# Issue Skill (`/issue`)

Grills down a problem or feature idea, then files a Forgejo (`fj`) or GitHub (`gh`) issue for it.

Usage: `/issue [problem or feature one-liner]`

## Step 1 — Grill (lightweight, max 2 rounds)

Pin down the issue before filing. Use the Skill tool `grilling` if available, else grill inline.

Use the grilling rounds format (numbered Q with recommended answer):

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Cover in at most 2 rounds:
1. **Problem vs feature** — bug report or feature request? What is the actual pain / desired outcome?
2. **Repro / acceptance criteria** — repro steps (bugs) or acceptance criteria (features).
3. **Scope / non-goals** — what is explicitly out of scope.
4. **Priority** — blocker, high, medium, low.

Do NOT over-grill — 2 rounds max, then confirm shared understanding with the user before filing.

## Step 2 — Detect host

```bash
# Must be inside a git repo
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "Not inside a git repository."
  exit 1
fi

# Prefer fj when this looks like a Forgejo repo and fj is available
if command -v fj >/dev/null 2>&1 && (git remote -v | grep -iE 'forgejo|codeberg' >/dev/null 2>&1 || [ -d ".forgejo" ] || [ -f ".forgejo/config" ] || fj issue search >/dev/null 2>&1); then
  USE_FJ=1
elif command -v gh >/dev/null 2>&1; then
  USE_GH=1
else
  echo "Neither gh nor fj is available. Please install gh (https://cli.github.com) or fj (forgejo-cli) and try again."
  exit 1
fi
```

Rules:
- If `git rev-parse --show-toplevel` succeeds AND (remote matches forgejo/codeberg OR `.forgejo/` exists OR `fj issue search` succeeds) AND `fj` is available → use `fj`.
- Else if `gh` is available → use `gh`.
- Else error out telling the user to install `gh` or `fj`.

## Step 3 — File issue

Check templates first when using `fj`:

```bash
fj issue templates
```

Then file with `fj` or `gh`:

```bash
# Forgejo
fj issue create "<title>" --body "<body>"

# GitHub
gh issue create --title "<title>" --body "<body>"
```

Body template:

```markdown
## Problem/Context
<what is broken or missing, who is affected, since when>

## Proposal/Acceptance criteria
<proposed fix or feature; checkboxes for acceptance criteria>
- [ ] ...

## Non-goals
<explicitly out of scope>

## Notes
<grill summary: key decisions from grilling, alternatives considered>
```

Guidelines:
- Reference glossary/ADRs by path (e.g. `docs/adr/0001-foo.md`) where relevant.
- Redact secrets — never paste tokens, passwords, or private keys into the title or body.

## Step 4 — Report back

Print the issue URL and/or number back to the user (e.g. `Created issue #42: https://...`).
