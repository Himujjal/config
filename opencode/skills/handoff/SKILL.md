---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff Skill (`/handoff`)

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

This skill is the step after `grill` — once grilling has reached a shared understanding, call this skill to write the plan down as a handoff document for the next session (typically picked up by `execute`).

## Where to write (mandatory)

- Write the handoff doc to the OS tempdir ONLY — never inside the repo:
  - Unix/macOS: `$TMPDIR` if set, else `/tmp`.
  - Windows: `%TEMP%`.
- Filename: `handoff-<slug>-<YYYYMMDD-HHMM>.md` (e.g. `handoff-auth-refactor-20260513-1430.md`).
- The handoff doc must NOT be committed to the repo. The tempdir doc is the source of truth.

## Pointer file (repo-local, git-ignored)

Write a tiny pointer file in the repo so the next session can find the tempdir doc:

- Path: `.slim/handoff/<slug>.md`
- Contents only (keep it small):
  ```md
  # Handoff: <title>
  Date: <YYYY-MM-DD HH:MM>
  Handoff doc: <absolute tempdir path>
  Goal: <one-line goal>
  Next steps: <checklist summary, e.g. `- [ ] step 1; - [ ] step 2`>
  ```
- The pointer file is git-ignored; never commit the full handoff content into the repo. (Document this convention here — do not modify any global `.gitignore` from this skill.)

Example:

```bash
# Resolve tempdir
TMP="${TMPDIR:-/tmp}"
# Write handoff doc
echo "..." > "$TMP/handoff-<slug>-<YYYYMMDD-HHMM>.md"
# Write pointer
mkdir -p .slim/handoff
printf '# Handoff: <title>\nDate: <date>\nHandoff doc: %s\nGoal: <goal>\nNext steps: <summary>\n' "$TMP/handoff-<slug>-<YYYYMMDD-HHMM>.md" > .slim/handoff/<slug>.md
```

## Document sections (required)

1. **Goal** — what the next session must achieve.
2. **Decisions** — key decisions with reasons (why each was chosen).
3. **Open questions** — unresolved items, each with who/what unblocks it.
4. **Suggested skills** — which skills the next agent should call the Skill tool for (e.g. `execute`, `pullrequest`, `commit`).
5. **Next steps** — checkbox list (`- [ ] ...`) in execution order. This is what `execute` consumes.
6. **Context pointers** — links/paths to relevant files, branches, specs, plans, issues, PRs.

## Rules

- Do NOT duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
- Redact any sensitive information, such as API keys, passwords, tokens, or personally identifiable information.
- If the user passed arguments (`$ARGUMENTS`), treat them as a description of what the next session will focus on and tailor the doc (Goal, Next steps ordering, Suggested skills) accordingly.
