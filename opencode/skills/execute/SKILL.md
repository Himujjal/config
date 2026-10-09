---
name: execute
description: Execute a handoff plan task-by-task, tracking progress in OpenCode todos.
argument-hint: "<path-to-handoff-doc-in-tempdir>"
---

# Execute Skill (`/execute`)

Execute a handoff plan produced by the `handoff` skill, one task at a time, with verification at each step.

## 1. Resolve input

Input is a path to the handoff doc in the OS tempdir. Accept either:

- (a) The absolute tempdir handoff path (e.g. `/tmp/handoff-auth-refactor-20260513-1430.md`), or
- (b) A repo-local pointer file at `.slim/handoff/<slug>.md` — read its `Handoff doc:` line and resolve to the absolute tempdir path.

If no path/args were given (`$ARGUMENTS` empty):

1. List `.slim/handoff/*.md` pointers (if any) plus `$TMPDIR/handoff-*.md` (Unix: `${TMPDIR:-/tmp}/handoff-*.md`; Windows: `%TEMP%\handoff-*.md`).
2. Ask the user which handoff to execute before proceeding.

```bash
ls .slim/handoff/*.md 2>/dev/null
ls "${TMPDIR:-/tmp}"/handoff-*.md 2>/dev/null
```

## 2. Load the plan

- Read the handoff doc at the resolved absolute path.
- Extract the **Next steps** checkbox list — that is the task list. Do not invent extra tasks.
- Reference the handoff doc by path; do not copy its full contents into the repo.

## 3. Set up progress tracking

OpenCode v2 has no todo tool, so track progress in a markdown progress file plus per-step user reports:

- Progress file: `.slim/execute/<slug>.md` (derive `<slug>` from the handoff filename).
- Header of the progress file must record:
  ```md
  # Execute: <slug>
  Handoff doc: <absolute tempdir handoff path>
  ```
- Mirror the handoff Next steps as checkboxes and check them off as you complete each one. Record decisions, clarifications, and verification results inline per task.
- Report todos to the user at each step (what is done / what is next).

## 4. Execute ONE task at a time

For each Next-step item in order:

1. Implement the single task.
2. Run minimal verification relevant to the change (build, test, or lint scoped to what changed — not the whole suite unless necessary).
3. Report the result (what changed + verification evidence) before moving on.
4. Stop on failure: do not proceed to the next task; surface the blocker with logs/evidence.

## 5. Ambiguity rule

- Never re-grill the plan. If a step is ambiguous, ask ONE focused clarification question, record the answer in the progress file, then continue.
- If the handoff doc itself is missing or unreadable, stop and ask the user for a valid path.

## 6. Completion

When all tasks are done (or blocked), give a concise summary:

- Tasks completed vs. remaining/blocked.
- Files changed.
- Verification evidence (commands run + outcomes).
- Progress file path and handoff doc path.
